import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// 렌즈 버튼의 순서. 화각이 넓은 렌즈가 왼쪽이다.
const lensOrder = [
  CameraLensType.ultraWide,
  CameraLensType.wide,
  CameraLensType.telephoto,
];

/// 렌즈 버튼의 글자. 망원의 배율은 기종마다 다르므로 숫자를 쓰지 않는다.
String lensLabel(CameraLensType lens) => switch (lens) {
  CameraLensType.ultraWide => '.5',
  CameraLensType.telephoto => '망원',
  _ => '1×',
};

/// 지금 렌즈와 디지털 줌으로 화면에 보여 줄 배율을 만든다.
///
/// 초광각은 0.5배로 계산한다. 망원은 렌즈의 배율을 모르므로 디지털 줌만 쓴다.
String zoomLabel(CameraLensType lens, double zoom) => switch (lens) {
  CameraLensType.ultraWide => '${(0.5 * zoom).toStringAsFixed(1)}×',
  CameraLensType.telephoto => '망원 ${zoom.toStringAsFixed(1)}×',
  _ => '${zoom.toStringAsFixed(1)}×',
};

/// 렌즈 버튼 줄. 지금 렌즈의 버튼은 노란색이고 지금 배율을 표시한다.
///
/// [lenses]가 1개 이하이면 지금 배율만 표시한다.
class LensBar extends StatelessWidget {
  const LensBar({
    super.key,
    required this.lenses,
    required this.current,
    required this.zoom,
    required this.onSelected,
  });

  final List<CameraLensType> lenses;
  final CameraLensType current;
  final double zoom;

  /// 렌즈 버튼을 누르면 부른다. 지금 렌즈를 누르면 1배로 돌아가는 데 쓴다.
  final ValueChanged<CameraLensType> onSelected;

  @override
  Widget build(BuildContext context) {
    final shown = lenses.length > 1 ? lenses : [current];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final lens in shown)
            _LensButton(
              label: lens == current ? zoomLabel(lens, zoom) : lensLabel(lens),
              selected: lens == current,
              onPressed: () => onSelected(lens),
            ),
        ],
      ),
    );
  }
}

class _LensButton extends StatelessWidget {
  const _LensButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minWidth: 38),
        height: 38,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.black54 : Colors.transparent,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.amber : Colors.white,
            fontSize: selected ? 13 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
