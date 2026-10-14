import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;

import '../models/photo_filter.dart';

/// 저장하는 사진의 긴 변의 최대 길이(픽셀).
const maxLongSide = 4032;

const _noiseSize = 256;

/// 입자 1개의 크기를 정한다. 화면 너비를 이 값으로 나눈 길이가 입자 1개이다.
/// 화면 표시와 저장 사진에서 입자가 같은 비율로 보인다.
const _grainCellsPerWidth = 600.0;

/// 입자용 회색 노이즈 이미지를 만든다. 앱을 시작할 때 한 번 만든다.
Future<ui.Image> createNoiseImage({int seed = 7}) async {
  final rnd = math.Random(seed);
  final pixels = Uint8List(_noiseSize * _noiseSize * 4);
  for (var i = 0; i < pixels.length; i += 4) {
    // 중간 회색(128)을 중심으로 절반의 폭만 쓴다. 폭이 넓으면 입자가 거칠다.
    final v = 64 + rnd.nextInt(128);
    pixels[i] = v;
    pixels[i + 1] = v;
    pixels[i + 2] = v;
    pixels[i + 3] = 255;
  }
  final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
  final descriptor = ui.ImageDescriptor.raw(
    buffer,
    width: _noiseSize,
    height: _noiseSize,
    pixelFormat: ui.PixelFormat.rgba8888,
  );
  final codec = await descriptor.instantiateCodec();
  final frame = await codec.getNextFrame();
  codec.dispose();
  descriptor.dispose();
  buffer.dispose();
  return frame.image;
}

/// 필터의 입자와 비네팅을 그린다.
///
/// 화면 표시와 저장이 이 함수를 함께 쓴다. 색 행렬은 이 함수가 그리지 않는다.
void paintFilterOverlays(
  Canvas canvas,
  Size size,
  PhotoFilter filter,
  ui.Image? noise,
) {
  final rect = Offset.zero & size;

  if (filter.grain > 0 && noise != null) {
    final scale = size.width / _grainCellsPerWidth;
    final matrix = Matrix4.diagonal3Values(scale, scale, 1).storage;
    final paint = Paint()
      ..shader = ui.ImageShader(
        noise,
        TileMode.repeated,
        TileMode.repeated,
        matrix,
      )
      ..blendMode = BlendMode.overlay
      ..color = Color.fromRGBO(0, 0, 0, filter.grain);
    canvas.drawRect(rect, paint);
  }

  if (filter.vignette > 0) {
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        rect.center,
        rect.size.longestSide * 0.75,
        [const Color(0x00000000), Color.fromRGBO(0, 0, 0, filter.vignette)],
        [0.55, 1.0],
      );
    canvas.drawRect(rect, paint);
  }
}

/// 화면에 표시하는 사진 위에 입자와 비네팅을 그린다.
class FilterOverlayPainter extends CustomPainter {
  const FilterOverlayPainter(this.filter, this.noise);

  final PhotoFilter filter;
  final ui.Image? noise;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    paintFilterOverlays(canvas, size, filter, noise);
  }

  @override
  bool shouldRepaint(FilterOverlayPainter old) =>
      old.filter != filter || old.noise != noise;
}

/// 촬영한 JPEG를 필터 적용 전의 기준 이미지로 만든다.
///
/// 가운데를 [aspect](너비 ÷ 높이) 비율로 자른다. [mirror]가 참이면 좌우를
/// 뒤집는다. 긴 변이 [maxLongSide]보다 길면 줄인다.
Future<ui.Image> prepareCapture(
  Uint8List bytes, {
  required double aspect,
  bool mirror = false,
}) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  codec.dispose();
  final src = frame.image;

  final crop = centerCrop(
    Size(src.width.toDouble(), src.height.toDouble()),
    aspect,
  );
  final scale = math.min(1.0, maxLongSide / crop.longestSide);
  final outW = (crop.width * scale).round();
  final outH = (crop.height * scale).round();

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  if (mirror) {
    canvas
      ..translate(outW.toDouble(), 0)
      ..scale(-1, 1);
  }
  canvas.drawImageRect(
    src,
    crop,
    Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()),
    Paint()..filterQuality = FilterQuality.high,
  );
  final picture = recorder.endRecording();
  final out = await picture.toImage(outW, outH);
  picture.dispose();
  src.dispose();
  return out;
}

/// [source] 크기의 가운데에서 [aspect] 비율의 가장 큰 사각형을 구한다.
Rect centerCrop(Size source, double aspect) {
  var w = source.width;
  var h = w / aspect;
  if (h > source.height) {
    h = source.height;
    w = h * aspect;
  }
  return Rect.fromLTWH((source.width - w) / 2, (source.height - h) / 2, w, h);
}

/// 기준 이미지에 필터를 적용한 새 이미지를 만든다.
Future<ui.Image> renderFiltered(
  ui.Image source,
  PhotoFilter filter,
  ui.Image? noise,
) async {
  final size = Size(source.width.toDouble(), source.height.toDouble());
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawImage(
    source,
    Offset.zero,
    Paint()..colorFilter = ColorFilter.matrix(filter.matrix.values),
  );
  paintFilterOverlays(canvas, size, filter, noise);
  final picture = recorder.endRecording();
  final out = await picture.toImage(source.width, source.height);
  picture.dispose();
  return out;
}

/// 이미지를 JPEG로 인코딩한다. 인코딩은 별도 isolate에서 실행한다.
Future<Uint8List> encodeJpeg(ui.Image image, {int quality = 92}) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (data == null) {
    throw StateError('이미지의 픽셀을 읽지 못했습니다.');
  }
  return compute(_encodeJpeg, (
    data.buffer.asUint8List(),
    image.width,
    image.height,
    quality,
  ));
}

Uint8List _encodeJpeg((Uint8List, int, int, int) args) {
  final (rgba, width, height, quality) = args;
  final image = img.Image.fromBytes(
    width: width,
    height: height,
    bytes: rgba.buffer,
    numChannels: 4,
  );
  return img.encodeJpg(image, quality: quality);
}
