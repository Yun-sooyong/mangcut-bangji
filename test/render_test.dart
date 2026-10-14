import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mangcut_bangji/data/filters.dart';
import 'package:mangcut_bangji/data/guides.dart';
import 'package:mangcut_bangji/models/photo_ratio.dart';
import 'package:mangcut_bangji/painting/filter_renderer.dart';
import 'package:mangcut_bangji/painting/guide_painter.dart';

// 그린 결과를 build/render_test/ 에 PNG로 저장한다. 눈으로 확인할 때 쓴다.
final _outDir = Directory('build/render_test');

Future<void> _writePng(ui.Image image, String name) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  _outDir.createSync(recursive: true);
  File('${_outDir.path}/$name').writeAsBytesSync(data!.buffer.asUint8List());
}

Future<ui.Image> _testPhoto(int w, int h) {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final rect = Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble());
  canvas.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.linear(
        rect.topLeft,
        rect.bottomLeft,
        const [Color(0xFF6FA8DC), Color(0xFFF6D7A8), Color(0xFF3D6B35)],
        [0, 0.55, 1],
      ),
  );
  canvas.drawCircle(
    Offset(w * 0.62, h * 0.4),
    w * 0.12,
    Paint()..color = const Color(0xFFE0452B),
  );
  canvas.drawRect(
    Rect.fromLTWH(w * 0.1, h * 0.7, w * 0.25, h * 0.2),
    Paint()..color = const Color(0xFF222222),
  );
  return recorder.endRecording().toImage(w, h);
}

void main() {
  test('centerCrop은 가운데에서 고른 비율의 영역을 구한다', () {
    const r4x3 = 3 / 4;
    const r16x9 = 9 / 16;
    // 16:9 영상에서 4:3을 자르면 위와 아래를 버린다.
    expect(
      centerCrop(const Size(1080, 1920), r4x3),
      const Rect.fromLTWH(0, 240, 1080, 1440),
    );
    // 4:3 영상에서 16:9를 자르면 왼쪽과 오른쪽을 버린다.
    expect(
      centerCrop(const Size(3024, 4032), r16x9),
      const Rect.fromLTWH(378, 0, 2268, 4032),
    );
    // 비율이 같으면 자르지 않는다.
    expect(
      centerCrop(const Size(1080, 1920), r16x9),
      const Rect.fromLTWH(0, 0, 1080, 1920),
    );
  });

  testWidgets('가이드 14종을 두 비율로 그린다', (tester) async {
    await tester.runAsync(() async {
      for (final ratio in PhotoRatio.values) {
        const cellW = 240.0, cols = 7, gap = 8.0;
        final cellH = cellW / ratio.aspect;
        final rows = (allGuides.length / cols).ceil();
        final sheetW = (cellW + gap) * cols + gap;
        final sheetH = (cellH + gap) * rows + gap;
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        canvas.drawRect(
          Rect.fromLTWH(0, 0, sheetW, sheetH),
          Paint()..color = const Color(0xFF1E2A38),
        );
        for (var i = 0; i < allGuides.length; i++) {
          canvas.save();
          canvas.translate(
            gap + (i % cols) * (cellW + gap),
            gap + (i ~/ cols) * (cellH + gap),
          );
          final size = Size(cellW, cellH);
          canvas.drawRect(
            Offset.zero & size,
            Paint()..color = const Color(0xFF7A8FA6),
          );
          GuidePainter(allGuides[i]).paint(canvas, size);
          canvas.restore();
        }
        final image = await recorder.endRecording().toImage(
          sheetW.round(),
          sheetH.round(),
        );
        await _writePng(image, 'guides_${ratio.name}.png');
      }
    });
  });

  testWidgets('필터를 적용해도 이미지의 크기는 같다', (tester) async {
    await tester.runAsync(() async {
      final noise = await createNoiseImage();
      final photo = await _testPhoto(300, 400);
      const cols = 6;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      for (var i = 0; i < filters.length; i++) {
        final out = await renderFiltered(photo, filters[i], noise);
        expect(out.width, 300);
        expect(out.height, 400);
        canvas.drawImage(
          out,
          Offset((i % cols) * 300.0, (i ~/ cols) * 400.0),
          Paint(),
        );
      }
      final rows = (filters.length / cols).ceil();
      final sheet = await recorder.endRecording().toImage(
        300 * cols,
        400 * rows,
      );
      await _writePng(sheet, 'filters.png');
    });
  });

  testWidgets('원본 필터는 픽셀을 바꾸지 않는다', (tester) async {
    await tester.runAsync(() async {
      final photo = await _testPhoto(60, 80);
      final out = await renderFiltered(photo, original, null);
      final a = await photo.toByteData();
      final b = await out.toByteData();
      expect(b!.buffer.asUint8List(), a!.buffer.asUint8List());
    });
  });

  testWidgets('촬영 사진을 고른 비율로 자르고 JPEG로 인코딩한다', (tester) async {
    await tester.runAsync(() async {
      final source = await _testPhoto(900, 1600);
      final png = await source.toByteData(format: ui.ImageByteFormat.png);
      final bytes = png!.buffer.asUint8List();

      final wide = await prepareCapture(bytes, aspect: PhotoRatio.r16x9.aspect);
      expect((wide.width, wide.height), (900, 1600));

      final base = await prepareCapture(bytes, aspect: PhotoRatio.r4x3.aspect);
      expect((base.width, base.height), (900, 1200));

      final jpeg = await encodeJpeg(base);
      expect(jpeg.sublist(0, 2), [0xFF, 0xD8]);
      final codec = await ui.instantiateImageCodec(jpeg);
      final frame = await codec.getNextFrame();
      expect((frame.image.width, frame.image.height), (900, 1200));
    });
  });

  testWidgets('mirror는 사진의 좌우를 뒤집는다', (tester) async {
    await tester.runAsync(() async {
      // 왼쪽 절반은 빨강, 오른쪽 절반은 파랑인 사진.
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 30, 80),
        Paint()..color = const Color(0xFFFF0000),
      );
      canvas.drawRect(
        const Rect.fromLTWH(30, 0, 30, 80),
        Paint()..color = const Color(0xFF0000FF),
      );
      final source = await recorder.endRecording().toImage(60, 80);
      final png = await source.toByteData(format: ui.ImageByteFormat.png);

      final mirrored = await prepareCapture(
        png!.buffer.asUint8List(),
        aspect: 3 / 4,
        mirror: true,
      );
      final data = await mirrored.toByteData();
      // 왼쪽 위 픽셀이 파랑이다.
      expect(data!.getUint8(0), lessThan(10));
      expect(data.getUint8(2), greaterThan(245));
    });
  });
}
