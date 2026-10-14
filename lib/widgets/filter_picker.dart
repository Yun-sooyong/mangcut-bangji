import 'package:flutter/material.dart';

import '../models/photo_filter.dart';

/// 필터를 고르는 UI. 묶음 탭과 그 묶음의 필터 목록을 보여 준다.
class FilterPicker extends StatelessWidget {
  const FilterPicker({
    super.key,
    required this.filters,
    required this.category,
    required this.selected,
    required this.onCategoryChanged,
    required this.onSelected,
  });

  final List<PhotoFilter> filters;
  final FilterCategory category;
  final PhotoFilter selected;
  final ValueChanged<FilterCategory> onCategoryChanged;
  final ValueChanged<PhotoFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final visible = [
      for (final f in filters)
        if (f.category == category) f,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SegmentedButton<FilterCategory>(
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          segments: [
            for (final c in FilterCategory.values)
              ButtonSegment(value: c, label: Text(c.label)),
          ],
          selected: {category},
          onSelectionChanged: (s) => onCategoryChanged(s.first),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: visible.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final filter = visible[i];
              return ChoiceChip(
                label: Text(filter.name),
                selected: filter == selected,
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
                onSelected: (_) => onSelected(filter),
              );
            },
          ),
        ),
      ],
    );
  }
}
