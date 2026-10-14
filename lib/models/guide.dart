import 'dart:ui';

/// 가이드를 이루는 도형 1개.
///
/// 좌표는 모두 화면 크기에 대한 비율(0.0–1.0)이다.
sealed class GuideShape {
  const GuideShape();

  /// 도형을 정하는 점. 좌표 범위 검사에 쓴다.
  Iterable<Offset> get points;
}

class GuideLine extends GuideShape {
  const GuideLine(this.a, this.b);

  final Offset a;
  final Offset b;

  @override
  Iterable<Offset> get points => [a, b];
}

class GuideRect extends GuideShape {
  const GuideRect(this.rect, {this.radius = 0});

  final Rect rect;

  /// 모서리 반지름. 화면 너비에 대한 비율이다.
  final double radius;

  @override
  Iterable<Offset> get points => [rect.topLeft, rect.bottomRight];
}

class GuideOval extends GuideShape {
  const GuideOval(this.rect);

  final Rect rect;

  @override
  Iterable<Offset> get points => [rect.topLeft, rect.bottomRight];
}

class GuidePath extends GuideShape {
  const GuidePath(this.points, {this.closed = false});

  @override
  final List<Offset> points;
  final bool closed;
}

class Guide {
  const Guide({
    required this.id,
    required this.name,
    required this.build,
    this.flippable = false,
  });

  final String id;
  final String name;

  /// 화면 비율에 맞는 도형을 만든다.
  ///
  /// [aspect]는 화면의 너비 ÷ 높이이다. 원처럼 모양을 유지해야 하는 도형은
  /// 이 값으로 높이를 계산한다.
  final List<GuideShape> Function(double aspect) build;

  /// 좌우 반전이 의미가 있는 가이드인지 나타낸다.
  final bool flippable;
}
