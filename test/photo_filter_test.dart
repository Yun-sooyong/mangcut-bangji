import 'package:flutter_test/flutter_test.dart';
import 'package:mangcut_bangji/data/filters.dart';
import 'package:mangcut_bangji/models/photo_filter.dart';

void main() {
  test('원본 행렬은 색을 바꾸지 않는다', () {
    expect(ColorMatrix.identity.transform(10, 120, 250), (10.0, 120.0, 250.0));
  });

  test('채도 0은 세 채널을 같게 만든다', () {
    final (r, g, b) = ColorMatrix.saturation(0).transform(200, 50, 20);
    expect(r, closeTo(g, 1e-9));
    expect(g, closeTo(b, 1e-9));
  });

  test('대비는 중간 회색을 유지한다', () {
    final (r, _, _) = ColorMatrix.contrast(1.5).transform(127.5, 127.5, 127.5);
    expect(r, closeTo(127.5, 1e-9));
  });

  test('fade는 검정을 올리고 흰색을 유지한다', () {
    final m = ColorMatrix.fade(0.1);
    expect(m.transform(0, 0, 0).$1, closeTo(25.5, 1e-9));
    expect(m.transform(255, 255, 255).$1, closeTo(255, 1e-9));
  });

  test('then은 앞 행렬을 먼저 적용한다', () {
    final a = ColorMatrix.gains(2, 1, 1);
    final b = ColorMatrix.brightness(0.1);
    // (50 × 2) + 25.5
    expect(a.then(b).transform(50, 0, 0).$1, closeTo(125.5, 1e-9));
    // (50 + 25.5) × 2
    expect(b.then(a).transform(50, 0, 0).$1, closeTo(151, 1e-9));
  });

  test('흑백 필터는 회색만 만든다', () {
    for (final id in ['mono', 'mono_film']) {
      final mono = filters.firstWhere((f) => f.id == id);
      final (r, g, b) = mono.matrix.transform(180, 90, 40);
      expect(r, closeTo(g, 1e-6), reason: id);
      expect(g, closeTo(b, 1e-6), reason: id);
    }
  });

  test('따뜻한 필터는 회색을 붉은 쪽으로, 차가운 필터는 푸른 쪽으로 옮긴다', () {
    for (final id in ['warm', 'warm_film']) {
      final f = filters.firstWhere((f) => f.id == id);
      final (r, _, b) = f.matrix.transform(128, 128, 128);
      expect(r, greaterThan(b), reason: id);
    }
    for (final id in ['cool', 'cool_film']) {
      final f = filters.firstWhere((f) => f.id == id);
      final (r, _, b) = f.matrix.transform(128, 128, 128);
      expect(b, greaterThan(r), reason: id);
    }
  });
}
