import 'dart:math' as math;
import 'dart:ui';

/// 앱 아이콘의 그리기 코드. plan.md 10장의 시안 E(인화 사진)이다.
///
/// 아이콘 PNG는 `test/icon_test.dart`가 이 함수로 만든다.
/// 그림은 1024×1024 좌표로 그리고, [size]에 맞게 줄인다.

const iconBackground = Color(0xFFE9733A);
const _paper = Color(0xFFFBF6EC);
const _sky = Color(0xFF2E4A5A);
const _sea = Color(0xFF1E3340);
const _sun = Color(0xFFF2A531);

/// [background]가 거짓이면 바탕을 그리지 않는다 (Android adaptive icon의 전경).
/// [scale]은 사진의 크기 배율이다. 전경은 잘리지 않도록 작게 그린다.
void paintAppIcon(
  Canvas canvas,
  double size, {
  bool background = true,
  double scale = 1.0,
}) {
  canvas.save();
  canvas.scale(size / 1024);
  if (background) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 1024, 1024),
      Paint()..color = iconBackground,
    );
  }

  // 가운데를 중심으로 줄이고 왼쪽으로 6° 기울인다.
  canvas
    ..translate(512, 512)
    ..scale(scale)
    ..rotate(-6 * math.pi / 180)
    ..translate(-512, -512);

  // 인화지. 아래 여백이 넓다.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(232, 182, 560, 660),
      const Radius.circular(24),
    ),
    Paint()..color = _paper,
  );

  // 사진: 하늘과 바다
  const photo = Rect.fromLTWH(280, 230, 464, 464);
  canvas.drawRect(photo, Paint()..color = _sky);
  canvas.drawRect(const Rect.fromLTWH(280, 540, 464, 154), Paint()..color = _sea);

  // 해. 삼분할 교차점(오른쪽 위)에 있다.
  final third = photo.width / 3;
  final sun = Offset(photo.left + third * 2, photo.top + third);
  canvas.drawCircle(sun, 56, Paint()..color = _sun);

  // 삼분할 선
  final line = Paint()
    ..color = const Color(0x59FFFFFF)
    ..strokeWidth = 6;
  for (var i = 1; i <= 2; i++) {
    final x = photo.left + third * i;
    final y = photo.top + third * i;
    canvas
      ..drawLine(Offset(x, photo.top), Offset(x, photo.bottom), line)
      ..drawLine(Offset(photo.left, y), Offset(photo.right, y), line);
  }

  canvas.restore();
}
