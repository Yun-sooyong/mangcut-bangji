import 'package:flutter/material.dart';

import '../models/scene.dart';

/// 장면을 고르는 가로 탭.
class SceneTabs extends StatelessWidget {
  const SceneTabs({
    super.key,
    required this.scenes,
    required this.selected,
    required this.onSelected,
  });

  final List<Scene> scenes;
  final Scene selected;
  final ValueChanged<Scene> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: scenes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 4),
        itemBuilder: (context, i) {
          final scene = scenes[i];
          final isSelected = scene == selected;
          return TextButton(
            onPressed: () => onSelected(scene),
            style: TextButton.styleFrom(
              foregroundColor: isSelected ? Colors.amber : Colors.white70,
              textStyle: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            child: Text(scene.name),
          );
        },
      ),
    );
  }
}
