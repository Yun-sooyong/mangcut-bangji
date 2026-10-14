import 'dart:math' as math;
import 'dart:ui';

import '../models/guide.dart';

// 좌표는 화면 크기에 대한 비율이다. (0,0)은 왼쪽 위, (1,1)은 오른쪽 아래이다.
// build가 받는 aspect는 화면의 너비 ÷ 높이이다. 원처럼 모양을 유지해야 하는
// 도형은 높이를 `너비 × aspect`로 계산한다.

const _phi = 1.6180339887;

final thirds = Guide(
  id: 'thirds',
  name: '삼분할',
  build: (_) => _grid(1 / 3, 2 / 3),
);

final goldenSection = Guide(
  id: 'golden_section',
  name: '황금 분할',
  build: (_) => _grid(1 - 1 / _phi, 1 / _phi),
);

final goldenSpiral = Guide(
  id: 'golden_spiral',
  name: '황금 나선',
  build: (_) => [GuidePath(_goldenSpiral())],
  flippable: true,
);

final center = Guide(
  id: 'center',
  name: '중앙',
  build: (aspect) => [
    GuideOval(
      Rect.fromCenter(
        center: const Offset(0.5, 0.5),
        width: 0.56,
        height: 0.56 * aspect,
      ),
    ),
  ],
);

final negativeSpace = Guide(
  id: 'negative_space',
  name: '여백',
  build: (_) => const [
    GuideRect(Rect.fromLTRB(0.06, 0.05, 0.94, 0.62), radius: 0.06),
  ],
);

final diagonal = Guide(
  id: 'diagonal',
  name: '대각선',
  build: (_) => const [GuideLine(Offset(0, 0), Offset(1, 1))],
  flippable: true,
);

final sCurve = Guide(
  id: 's_curve',
  name: 'S자',
  build: (_) => [GuidePath(_sCurve())],
  flippable: true,
);

final symmetry = Guide(
  id: 'symmetry',
  name: '대칭',
  build: (_) => const [GuideLine(Offset(0.5, 0), Offset(0.5, 1))],
);

final frame = Guide(
  id: 'frame',
  name: '프레임 속 프레임',
  build: (aspect) => [GuidePath(_arch(aspect), closed: true)],
);

final triangle = Guide(
  id: 'triangle',
  name: '삼각형',
  build: (_) => const [
    GuidePath([
      Offset(0.5, 0.2),
      Offset(0.9, 0.85),
      Offset(0.1, 0.85),
    ], closed: true),
  ],
);

final repetition = Guide(
  id: 'repetition',
  name: '반복',
  build: (_) => const [
    GuideRect(Rect.fromLTRB(0.08, 0.3, 0.32, 0.7)),
    GuideRect(Rect.fromLTRB(0.38, 0.3, 0.62, 0.7)),
    GuideRect(Rect.fromLTRB(0.68, 0.3, 0.92, 0.7)),
  ],
);

final vanishingPoint = Guide(
  id: 'vanishing_point',
  name: '소실점',
  build: (_) => const [
    GuideRect(Rect.fromLTRB(0.4, 0.42, 0.6, 0.58)),
    GuideLine(Offset(0, 0), Offset(0.4, 0.42)),
    GuideLine(Offset(1, 0), Offset(0.6, 0.42)),
    GuideLine(Offset(0, 1), Offset(0.4, 0.58)),
    GuideLine(Offset(1, 1), Offset(0.6, 0.58)),
  ],
);

final leadingLines = Guide(
  id: 'leading_lines',
  name: '유도선',
  build: _leadingLines,
);

final vShape = Guide(
  id: 'v_shape',
  name: 'V자',
  build: (_) => const [
    GuideLine(Offset(0.1, 0.05), Offset(0.5, 0.85)),
    GuideLine(Offset(0.9, 0.05), Offset(0.5, 0.85)),
  ],
);

final allGuides = <Guide>[
  thirds,
  goldenSection,
  goldenSpiral,
  center,
  negativeSpace,
  diagonal,
  sCurve,
  symmetry,
  frame,
  triangle,
  repetition,
  vanishingPoint,
  leadingLines,
  vShape,
];

List<GuideShape> _grid(double a, double b) => [
  GuideLine(Offset(a, 0), Offset(a, 1)),
  GuideLine(Offset(b, 0), Offset(b, 1)),
  GuideLine(Offset(0, a), Offset(1, a)),
  GuideLine(Offset(0, b), Offset(1, b)),
];

/// 황금 나선의 점을 만든다.
///
/// 가로 황금 사각형(φ×1)에서 정사각형을 반복해서 잘라 내고, 정사각형마다
/// 4분원을 그린다. 그 다음 가로와 세로를 바꿔서 세로 화면에 맞춘다.
/// 나선은 화면 전체에 맞춰 늘어난다.
List<Offset> _goldenSpiral() {
  const arcs = 8;
  const stepsPerArc = 12;
  final pts = <Offset>[];
  var x = 0.0, y = 0.0, w = _phi, h = 1.0;
  for (var k = 0; k < arcs; k++) {
    late double cx, cy, r, start;
    switch (k % 4) {
      case 0: // 왼쪽 정사각형
        r = h;
        cx = x + h;
        cy = y + h;
        start = math.pi;
        x += h;
        w -= h;
      case 1: // 위쪽 정사각형
        r = w;
        cx = x;
        cy = y + w;
        start = 1.5 * math.pi;
        y += w;
        h -= w;
      case 2: // 오른쪽 정사각형
        r = h;
        cx = x + w - h;
        cy = y;
        start = 0;
        w -= h;
      case 3: // 아래쪽 정사각형
        r = w;
        cx = x + w;
        cy = y + h - w;
        start = 0.5 * math.pi;
        h -= w;
    }
    for (var i = k == 0 ? 0 : 1; i <= stepsPerArc; i++) {
      final t = start + (math.pi / 2) * i / stepsPerArc;
      final px = cx + r * math.cos(t);
      final py = cy + r * math.sin(t);
      // 가로 사각형의 (px, py)를 세로 화면의 비율 좌표로 바꾼다.
      pts.add(
        Offset(py.clamp(0, 1).toDouble(), (px / _phi).clamp(0, 1).toDouble()),
      );
    }
  }
  return pts;
}

List<Offset> _sCurve() {
  const steps = 48;
  return [
    for (var i = 0; i <= steps; i++)
      Offset(
        0.5 + 0.3 * math.sin(2 * math.pi * i / steps),
        0.08 + 0.84 * i / steps,
      ),
  ];
}

/// 아치 모양. 윗변은 반원이다. 반원이 원으로 보이도록 세로 반지름을 계산한다.
List<Offset> _arch(double aspect) {
  const steps = 24;
  const rx = 0.32, cy = 0.42;
  final ry = rx * aspect;
  return [
    const Offset(0.5 - rx, 0.88),
    for (var i = 0; i <= steps; i++)
      Offset(
        0.5 - rx * math.cos(math.pi * i / steps),
        cy - ry * math.sin(math.pi * i / steps),
      ),
    const Offset(0.5 + rx, 0.88),
  ];
}

/// 원 1개와, 화면 가장자리에서 원으로 모이는 직선들.
List<GuideShape> _leadingLines(double aspect) {
  const c = Offset(0.5, 0.42);
  const rx = 0.09;
  final ry = rx * aspect;
  const starts = [
    Offset(0, 1),
    Offset(0.3, 1),
    Offset(0.7, 1),
    Offset(1, 1),
    Offset(0, 0.72),
    Offset(1, 0.72),
  ];
  return [
    GuideOval(Rect.fromCenter(center: c, width: rx * 2, height: ry * 2)),
    for (final s in starts) GuideLine(s, _onEllipse(c, rx, ry, s)),
  ];
}

/// [from]에서 타원의 중심으로 가는 직선이 타원과 만나는 점.
Offset _onEllipse(Offset c, double rx, double ry, Offset from) {
  final d = from - c;
  final k =
      1 / math.sqrt((d.dx * d.dx) / (rx * rx) + (d.dy * d.dy) / (ry * ry));
  return c + d * k;
}
