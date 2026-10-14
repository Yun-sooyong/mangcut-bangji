import 'package:flutter/material.dart';

import '../models/guide.dart';
import '../models/photo_ratio.dart';
import '../painting/guide_painter.dart';

/// 촬영 화면 아래쪽의 조작 줄. 칸 5개이고 셔터는 항상 가운데에 있다.
///
/// 비율, 가이드 패널, 셔터, 가이드 반전, 카메라 전환의 순서이다.
class ControlBar extends StatelessWidget {
  const ControlBar({
    super.key,
    required this.ratio,
    required this.guide,
    required this.panelOpen,
    required this.canFlip,
    required this.canSwitch,
    required this.shutterEnabled,
    required this.onRatio,
    required this.onGuide,
    required this.onShutter,
    required this.onFlip,
    required this.onSwitch,
  });

  final PhotoRatio ratio;
  final Guide? guide;
  final bool panelOpen;
  final bool canFlip;
  final bool canSwitch;
  final bool shutterEnabled;
  final VoidCallback onRatio;
  final VoidCallback onGuide;
  final VoidCallback onShutter;
  final VoidCallback onFlip;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Expanded(child: Center(child: _RatioButton(ratio, onRatio))),
          Expanded(
            child: Center(child: _GuideButton(guide, panelOpen, onGuide)),
          ),
          _ShutterButton(enabled: shutterEnabled, onPressed: onShutter),
          Expanded(
            child: Center(
              child: _BarIconButton(
                icon: Icons.flip,
                tooltip: '가이드 좌우 반전',
                onPressed: canFlip ? onFlip : null,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: _BarIconButton(
                icon: Icons.cameraswitch_outlined,
                tooltip: '카메라 전환',
                onPressed: canSwitch ? onSwitch : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatioButton extends StatelessWidget {
  const _RatioButton(this.ratio, this.onPressed);

  final PhotoRatio ratio;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '사진 비율 ${ratio.label}',
      excludeSemantics: true,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white54),
          minimumSize: const Size(52, 36),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        child: Text(ratio.label),
      ),
    );
  }
}

class _GuideButton extends StatelessWidget {
  const _GuideButton(this.guide, this.panelOpen, this.onPressed);

  final Guide? guide;
  final bool panelOpen;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = panelOpen ? Colors.amber : Colors.white70;
    final guide = this.guide;
    return Semantics(
      button: true,
      label: panelOpen ? '가이드 목록 접기' : '가이드 목록 펼치기',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 33,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white10,
            border: Border.all(color: color, width: panelOpen ? 2 : 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: guide == null
              ? Icon(Icons.grid_off, size: 18, color: color)
              : CustomPaint(
                  painter: GuidePainter(guide, strokeWidth: 1, color: color),
                ),
        ),
      ),
    );
  }
}

class _BarIconButton extends StatelessWidget {
  const _BarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      color: Colors.white,
      disabledColor: Colors.white24,
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: '촬영',
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            padding: const EdgeInsets.all(4),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
