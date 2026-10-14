import 'package:flutter/material.dart';

/// 누른 곳의 초점 사각형과 세로 노출 슬라이더.
///
/// [point]는 미리보기 안의 위치(픽셀)이다. 슬라이더는 사각형의 오른쪽에
/// 그린다. 오른쪽 가장자리에 가까우면 왼쪽에 그린다.
class ExposureControl extends StatelessWidget {
  const ExposureControl({
    super.key,
    required this.point,
    required this.viewSize,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final Offset point;
  final Size viewSize;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  static const _box = 72.0;
  static const _sliderLength = 150.0;
  static const _sliderWidth = 40.0;

  @override
  Widget build(BuildContext context) {
    final boxLeft = (point.dx - _box / 2).clamp(0.0, viewSize.width - _box);
    final boxTop = (point.dy - _box / 2).clamp(0.0, viewSize.height - _box);
    final rightSide = boxLeft + _box + _sliderWidth <= viewSize.width;
    final sliderLeft = rightSide
        ? boxLeft + _box
        : (boxLeft - _sliderWidth).clamp(0.0, viewSize.width);
    final sliderTop = (point.dy - _sliderLength / 2).clamp(
      0.0,
      viewSize.height - _sliderLength,
    );

    return Stack(
      children: [
        Positioned(
          left: boxLeft,
          top: boxTop,
          child: IgnorePointer(
            child: Container(
              width: _box,
              height: _box,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber, width: 1.5),
              ),
            ),
          ),
        ),
        Positioned(
          left: sliderLeft,
          top: sliderTop,
          width: _sliderWidth,
          height: _sliderLength,
          child: Semantics(
            label: '밝기',
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 1.5,
                  activeTrackColor: Colors.amber,
                  inactiveTrackColor: Colors.amber,
                  thumbColor: Colors.amber,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const _SunThumb(),
                ),
                child: Slider(
                  value: value.clamp(min, max),
                  min: min,
                  max: max,
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 슬라이더의 손잡이. 해 모양 아이콘을 그린다.
class _SunThumb extends SliderComponentShape {
  const _SunThumb();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(24, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final icon = Icons.wb_sunny;
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 22,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.amber,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final canvas = context.canvas;
    // 슬라이더가 돌아가 있으므로 아이콘을 반대로 돌려서 똑바로 그린다.
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(1.5707963267948966);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }
}

/// 노출 값이 0이 아닐 때 남기는 작은 표시. 누르면 0으로 돌아간다.
class ExposureBadge extends StatelessWidget {
  const ExposureBadge({super.key, required this.value, required this.onReset});

  final double value;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final sign = value > 0 ? '+' : '−';
    return Semantics(
      button: true,
      label: '밝기 ${value.toStringAsFixed(1)}, 누르면 초기화',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onReset,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '☀ $sign${value.abs().toStringAsFixed(1)}',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
