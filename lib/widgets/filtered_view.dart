import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../models/photo_filter.dart';
import '../painting/filter_renderer.dart';

/// [child]에 필터를 적용해서 보여 준다.
///
/// 색 행렬을 적용한 다음 입자와 비네팅을 겹친다. 순서는 [renderFiltered]와 같다.
class FilteredView extends StatelessWidget {
  const FilteredView({
    super.key,
    required this.filter,
    required this.noise,
    required this.child,
  });

  final PhotoFilter filter;
  final ui.Image? noise;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.matrix(filter.matrix.values),
          child: child,
        ),
        IgnorePointer(
          child: CustomPaint(painter: FilterOverlayPainter(filter, noise)),
        ),
      ],
    );
  }
}
