import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/scenes.dart';
import '../models/guide.dart';
import '../models/photo_ratio.dart';
import '../models/scene.dart';
import '../painting/filter_renderer.dart';
import '../painting/guide_painter.dart';
import '../widgets/guide_picker.dart';
import '../widgets/scene_tabs.dart';
import 'result_screen.dart';

/// 촬영 화면. 미리보기 위에 가이드를 표시한다. 필터는 결과 화면에서 적용한다.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.noise});

  final ui.Image? noise;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = const [];
  CameraDescription? _camera;
  CameraController? _controller;
  String? _error;
  bool _busy = false;
  bool _opening = false;

  PhotoRatio _ratio = PhotoRatio.r4x3;
  Scene _scene = scenes.first;
  Guide? _guide = scenes.first.guides.first;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final camera = _camera;
    if (camera == null) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
      setState(() => _controller = null);
    } else if (state == AppLifecycleState.resumed &&
        _controller == null &&
        !_opening) {
      // 권한 창이 뜨면 앱이 inactive가 되었다가 resumed로 돌아온다.
      // 이때 카메라를 여는 중이면 다시 열지 않는다.
      _open(camera);
    }
  }

  Future<void> _loadCameras() async {
    try {
      _cameras = await availableCameras();
    } on CameraException catch (e) {
      _showError(e);
      return;
    }
    if (_cameras.isEmpty) {
      if (mounted) setState(() => _error = '이 기기에서 카메라를 찾지 못했습니다.');
      return;
    }
    final back = _cameras.where(
      (c) => c.lensDirection == CameraLensDirection.back,
    );
    await _open(back.isNotEmpty ? back.first : _cameras.first);
  }

  Future<void> _open(CameraDescription camera) async {
    final old = _controller;
    final controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    setState(() {
      _camera = camera;
      _controller = null;
      _error = null;
    });
    _opening = true;
    try {
      await old?.dispose();
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
    } on CameraException catch (e) {
      await controller.dispose();
      _showError(e);
      return;
    } finally {
      _opening = false;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
  }

  void _showError(CameraException e) {
    if (!mounted) return;
    final denied = e.code.contains('AccessDenied');
    setState(() {
      _error = denied
          ? '카메라 권한이 없습니다.\n설정에서 카메라 권한을 허용하십시오.'
          : '카메라를 시작하지 못했습니다.\n(${e.code})\n${e.description ?? ''}';
    });
  }

  void _switchCamera() {
    final current = _camera;
    if (current == null || _busy || _opening) return;
    final wanted = current.lensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    final next = _cameras.where((c) => c.lensDirection == wanted);
    if (next.isNotEmpty) _open(next.first);
  }

  Future<void> _capture() async {
    final controller = _controller;
    final camera = _camera;
    if (controller == null || camera == null || _busy) return;
    setState(() => _busy = true);
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      // 전면 카메라의 미리보기는 거울처럼 보인다. 사진도 같게 맞춘다.
      final image = await prepareCapture(
        bytes,
        aspect: _ratio.aspect,
        mirror: camera.lensDirection == CameraLensDirection.front,
      );
      if (!mounted) {
        image.dispose();
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(image: image, noise: widget.noise),
        ),
      );
    } on CameraException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('사진을 찍지 못했습니다. (${e.code})')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _selectScene(Scene scene) {
    setState(() {
      _scene = scene;
      _guide = scene.guides.first;
      _flipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        // 4:3에서는 미리보기와 조작부가 겹치지 않는다.
        // 16:9에서는 조작부가 미리보기의 아래쪽 위에 반투명하게 겹친다.
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: AspectRatio(
                aspectRatio: _ratio.aspect,
                child: _buildViewfinder(),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ColoredBox(
                color: Colors.black54,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SceneTabs(
                      scenes: scenes,
                      selected: _scene,
                      onSelected: _selectScene,
                    ),
                    GuidePicker(
                      guides: _scene.guides,
                      selected: _guide,
                      onSelected: (g) => setState(() {
                        _guide = g;
                        _flipped = false;
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: _ShutterButton(
                        enabled: _controller != null && !_busy,
                        onPressed: _capture,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewfinder() {
    final guide = _guide;
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildPreview(),
        if (guide != null && _error == null)
          IgnorePointer(
            child: CustomPaint(painter: GuidePainter(guide, flipped: _flipped)),
          ),
        Positioned(
          top: 8,
          left: 8,
          child: _RatioButton(
            ratio: _ratio,
            onChanged: (r) => setState(() => _ratio = r),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Column(
            children: [
              if (_cameras.length > 1)
                _OverlayButton(
                  icon: Icons.cameraswitch_outlined,
                  tooltip: '카메라 전환',
                  onPressed: _switchCamera,
                ),
              if (guide != null && guide.flippable)
                _OverlayButton(
                  icon: Icons.flip,
                  tooltip: '가이드 좌우 반전',
                  onPressed: () => setState(() => _flipped = !_flipped),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final error = _error;
    if (error != null) {
      return ColoredBox(
        color: const Color(0xFF1A1A1A),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
          ),
        ),
      );
    }
    final controller = _controller;
    final previewSize = controller?.value.previewSize;
    if (controller == null || previewSize == null) {
      return const ColoredBox(
        color: Color(0xFF1A1A1A),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    // previewSize는 가로 기준이다. 세로 화면에서는 너비와 높이를 바꾼다.
    // 미리보기의 가운데를 고른 비율로 잘라서 저장 사진과 같은 영역을 보여 준다.
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _RatioButton extends StatelessWidget {
  const _RatioButton({required this.ratio, required this.onChanged});

  final PhotoRatio ratio;
  final ValueChanged<PhotoRatio> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PhotoRatio>(
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.amber
              : Colors.black45,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.black
              : Colors.white,
        ),
      ),
      segments: [
        for (final r in PhotoRatio.values)
          ButtonSegment(value: r, label: Text(r.label)),
      ],
      selected: {ratio},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: IconButton.filled(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          backgroundColor: Colors.black45,
          foregroundColor: Colors.white,
        ),
      ),
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
