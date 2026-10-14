import 'package:flutter/material.dart';

import '../models/guide.dart';
import '../painting/guide_painter.dart';

/// 가이드를 고르는 가로 목록. 첫 항목은 "없음"이다.
class GuidePicker extends StatelessWidget {
  const GuidePicker({
    super.key,
    required this.guides,
    required this.selected,
    required this.onSelected,
  });

  final List<Guide> guides;
  final Guide? selected;
  final ValueChanged<Guide?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: guides.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final guide = i == 0 ? null : guides[i - 1];
          return _GuideTile(
            guide: guide,
            isSelected: guide == selected,
            onTap: () => onSelected(guide),
          );
        },
      ),
    );
  }
}

class _GuideTile extends StatelessWidget {
  const _GuideTile({
    required this.guide,
    required this.isSelected,
    required this.onTap,
  });

  final Guide? guide;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.amber : Colors.white70;
    final guide = this.guide;
    return Semantics(
      button: true,
      selected: isSelected,
      label: guide?.name ?? '가이드 없음',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 60,
          child: Column(
            children: [
              Container(
                width: 39,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  border: Border.all(color: color, width: isSelected ? 2 : 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: guide == null
                    ? Icon(Icons.block, size: 18, color: color)
                    : CustomPaint(
                        painter: GuidePainter(
                          guide,
                          strokeWidth: 1,
                          color: color,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              ExcludeSemantics(
                child: Text(
                  guide?.name ?? '없음',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
