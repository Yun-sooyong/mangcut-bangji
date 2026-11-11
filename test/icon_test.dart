import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import '../tool/icon_painter.dart';

// 아이콘 PNG를 다시 만들 때:
//   UPDATE_ICON=1 flutter test test/icon_test.dart
//   dart run flutter_launcher_icons
// UPDATE_ICON이 없으면 그림만 확인하고 파일은 바꾸지 않는다.
const _size = 1024;

/// 아이콘을 그린다. 전경(foreground)은 바탕 없이, 가운데 안전 영역 안에 그린다.
Future<ui.Image> _render({required bool foreground}) {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  paintAppIcon(
    canvas,
    _size.toDouble(),
    background: !foreground,
    scale: foreground ? 0.62 : 1.0,
  );
  return recorder.endRecording().toImage(_size, _size);
}

Future<List<int>> _rgba(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  return data!.buffer.asUint8List();
}

int _alphaAt(List<int> rgba, int x, int y) => rgba[(y * _size + x) * 4 + 3];

Future<void> _save(ui.Image image, String path) async {
  if (Platform.environment['UPDATE_ICON'] == null) return;
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(png!.buffer.asUint8List());
}

void main() {
  test('아이콘은 모든 픽셀이 불투명하다 (iOS는 투명을 허용하지 않는다)', () async {
    final image = await _render(foreground: false);
    final rgba = await _rgba(image);
    for (var i = 3; i < rgba.length; i += 4) {
      expect(rgba[i], 255);
    }
    await _save(image, 'assets/icon/icon.png');
  });

  test('전경은 바탕이 투명하고 가운데 안전 영역 안에 있다', () async {
    final image = await _render(foreground: true);
    final rgba = await _rgba(image);
    // adaptive icon은 108dp 중 가운데 지름 66dp의 원만 반드시 보인다.
    const safeRadius = _size * 66 / 108 / 2;
    const c = _size / 2;
    for (var y = 0; y < _size; y += 4) {
      for (var x = 0; x < _size; x += 4) {
        final dx = x - c, dy = y - c;
        if (dx * dx + dy * dy > safeRadius * safeRadius) {
          expect(_alphaAt(rgba, x, y), 0, reason: '($x, $y)');
        }
      }
    }
    expect(_alphaAt(rgba, 512, 512), 255);
    await _save(image, 'assets/icon/icon_foreground.png');
  });
}
