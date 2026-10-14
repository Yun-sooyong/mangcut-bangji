import 'package:flutter/widgets.dart';

import '../models/guide.dart';

/// 가이드 1개를 그린다. 비율 좌표에 화면 크기를 곱해서 그린다.
class GuidePainter extends CustomPainter {
  const GuidePainter(
    this.guide, {
    this.flipped = false,
    this.strokeWidth = 1.5,
    this.color = const Color(0xFFFFFFFF),
  });

  final Guide guide;
  final bool flipped;
  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (final shape in guide.build(size.width / size.height)) {
      switch (shape) {
        case GuideLine(:final a, :final b):
          path
            ..moveTo(a.dx * size.width, a.dy * size.height)
            ..lineTo(b.dx * size.width, b.dy * size.height);
        case GuideRect(:final rect, :final radius):
          path.addRRect(
            RRect.fromRectAndRadius(
              _scale(rect, size),
              Radius.circular(radius * size.width),
            ),
          );
        case GuideOval(:final rect):
          path.addOval(_scale(rect, size));
        case GuidePath(:final points, :final closed):
          path.addPolygon([
            for (final p in points)
              Offset(p.dx * size.width, p.dy * size.height),
          ], closed);
      }
    }

    if (flipped && guide.flippable) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }

    // 밝은 장면에서도 보이도록 어두운 선을 먼저 그린다.
    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 1.5
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0x59000000);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    canvas
      ..drawPath(path, shadow)
      ..drawPath(path, line);
  }

  Rect _scale(Rect r, Size size) => Rect.fromLTRB(
    r.left * size.width,
    r.top * size.height,
    r.right * size.width,
    r.bottom * size.height,
  );

  @override
  bool shouldRepaint(GuidePainter old) =>
      old.guide != guide ||
      old.flipped != flipped ||
      old.strokeWidth != strokeWidth ||
      old.color != color;
}
