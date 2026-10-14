import 'dart:async';
import 'dart:math' as math;
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
import '../widgets/control_bar.dart';
import '../widgets/exposure_control.dart';
import '../widgets/guide_picker.dart';
import '../widgets/lens_bar.dart';
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

  /// 장면 탭과 가이드 목록을 펼쳤는지. 처음에는 펼친다.
  bool _panelOpen = true;

  /// 디지털 줌. 렌즈마다 따로이고 카메라를 다시 열면 최소 값으로 돌아간다.
  double _zoom = 1;
  double _minZoom = 1;
  double _maxZoom = 1;
  double _zoomAtScaleStart = 1;
  final _zoomSender = _LatestOnly();

  /// 노출 보정(EV). 카메라를 다시 열면 0으로 돌아간다.
  double _exposure = 0;
  double _minExposure = 0;
  double _maxExposure = 0;
  final _exposureSender = _LatestOnly();

  /// 초점 사각형과 노출 슬라이더의 위치(미리보기 안의 픽셀). null이면 숨긴다.
  Offset? _focusPoint;
  Timer? _focusTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusTimer?.cancel();
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
    await _open(_mainBackCamera() ?? _cameras.first);
  }

  Future<void> _open(CameraDescription camera) async {
    final old = _controller;
    final controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    _focusTimer?.cancel();
    setState(() {
      _camera = camera;
      _controller = null;
      _error = null;
      _focusPoint = null;
    });
    _opening = true;
    try {
      await old?.dispose();
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      _minZoom = await controller.getMinZoomLevel();
      // 10배보다 큰 디지털 줌은 화질이 너무 낮다.
      _maxZoom = math.max(
        _minZoom,
        math.min(await controller.getMaxZoomLevel(), 10),
      );
      _zoom = _minZoom;
      // 기기의 범위가 넓어도 ±2 EV만 쓴다.
      _minExposure = math.max(await controller.getMinExposureOffset(), -2);
      _maxExposure = math.min(await controller.getMaxExposureOffset(), 2);
      _exposure = 0;
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
    final next = wanted == CameraLensDirection.back
        ? _mainBackCamera()
        : _cameras.where((c) => c.lensDirection == wanted).firstOrNull;
    if (next != null) _open(next);
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

  /// 후면의 기본 카메라. 광각 렌즈가 있으면 광각이다.
  CameraDescription? _mainBackCamera() {
    final back = _cameras.where(
      (c) => c.lensDirection == CameraLensDirection.back,
    );
    return back.where((c) => c.lensType == CameraLensType.wide).firstOrNull ??
        back.firstOrNull;
  }

  /// 지금 방향(전면 또는 후면)의 렌즈 종류. 렌즈 버튼의 순서로 정렬한다.
  List<CameraLensType> _lensTypes() {
    final direction = _camera?.lensDirection;
    final types = {
      for (final c in _cameras)
        if (c.lensDirection == direction) _lensTypeOf(c),
    };
    return [
      for (final t in lensOrder)
        if (types.contains(t)) t,
    ];
  }

  /// 종류를 모르는 렌즈는 광각으로 본다.
  static CameraLensType _lensTypeOf(CameraDescription c) =>
      lensOrder.contains(c.lensType) ? c.lensType : CameraLensType.wide;

  void _selectLens(CameraLensType lens) {
    final camera = _camera;
    if (camera == null || _busy || _opening) return;
    if (_lensTypeOf(camera) == lens) {
      _setZoom(_minZoom);
      return;
    }
    final next = _cameras.where(
      (c) => c.lensDirection == camera.lensDirection && _lensTypeOf(c) == lens,
    );
    if (next.isNotEmpty) _open(next.first);
  }

  /// 줌을 바꾼다. 핀치 중에는 호출이 많으므로 마지막 값만 카메라에 보낸다.
  void _setZoom(double value) {
    final zoom = value.clamp(_minZoom, _maxZoom);
    if (zoom == _zoom) return;
    setState(() => _zoom = zoom);
    _zoomSender.send(zoom, (v) async => _controller?.setZoomLevel(v));
  }

  /// 누른 곳에 초점과 노출을 맞추고 노출 슬라이더를 보여 준다.
  Future<void> _focusAt(Offset local, Size viewSize) async {
    final controller = _controller;
    final previewSize = controller?.value.previewSize;
    if (controller == null || previewSize == null) return;
    // previewSize는 가로 기준이다. 세로 화면의 비율로 바꾼다.
    final point = viewToSource(
      Offset(local.dx / viewSize.width, local.dy / viewSize.height),
      viewSize.width / viewSize.height,
      previewSize.height / previewSize.width,
    );
    setState(() => _focusPoint = local);
    _restartFocusTimer();
    try {
      if (controller.value.focusPointSupported) {
        await controller.setFocusPoint(point);
      }
      if (controller.value.exposurePointSupported) {
        await controller.setExposurePoint(point);
      }
    } on CameraException {
      // 이 렌즈가 초점이나 노출의 위치 지정을 지원하지 않는다. 슬라이더는 쓸 수 있다.
    }
  }

  void _setExposure(double value) {
    setState(() => _exposure = value);
    _restartFocusTimer();
    _exposureSender.send(value, (v) async => _controller?.setExposureOffset(v));
  }

  /// 3초 동안 조작하지 않으면 초점 사각형과 슬라이더를 숨긴다.
  void _restartFocusTimer() {
    _focusTimer?.cancel();
    _focusTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _focusPoint = null);
    });
  }

  bool _hasLens(CameraLensDirection direction) =>
      _cameras.any((c) => c.lensDirection == direction);

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_controller != null && _camera != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LensBar(
                            lenses: _lensTypes(),
                            current: _lensTypeOf(_camera!),
                            zoom: _zoom,
                            onSelected: _selectLens,
                          ),
                          if (_exposure != 0) ...[
                            const SizedBox(width: 8),
                            ExposureBadge(
                              value: _exposure,
                              onReset: () => _setExposure(0),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ColoredBox(
                    color: Colors.black54,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          child: _panelOpen
                              ? Column(
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
                                  ],
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                        ControlBar(
                          ratio: _ratio,
                          guide: _guide,
                          panelOpen: _panelOpen,
                          canFlip: _guide?.flippable ?? false,
                          canSwitch:
                              _hasLens(CameraLensDirection.front) &&
                              _hasLens(CameraLensDirection.back),
                          shutterEnabled: _controller != null && !_busy,
                          onRatio: () => setState(() => _ratio = _ratio.next),
                          onGuide: () =>
                              setState(() => _panelOpen = !_panelOpen),
                          onShutter: _capture,
                          onFlip: () => setState(() => _flipped = !_flipped),
                          onSwitch: _switchCamera,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewfinder() {
    final guide = _guide;
    return LayoutBuilder(
      builder: (context, constraints) =>
          _buildViewfinderBody(guide, constraints.biggest),
    );
  }

  Widget _buildViewfinderBody(Guide? guide, Size size) {
    final focusPoint = _focusPoint;
    return GestureDetector(
      onTapUp: (d) => _focusAt(d.localPosition, size),
      onScaleStart: (_) => _zoomAtScaleStart = _zoom,
      onScaleUpdate: (d) {
        if (d.pointerCount >= 2) _setZoom(_zoomAtScaleStart * d.scale);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildPreview(),
          if (guide != null && _error == null)
            IgnorePointer(
              child: CustomPaint(
                painter: GuidePainter(guide, flipped: _flipped),
              ),
            ),
          if (focusPoint != null && _controller != null)
            ExposureControl(
              point: focusPoint,
              viewSize: size,
              value: _exposure,
              min: _minExposure,
              max: _maxExposure,
              onChanged: _setExposure,
            ),
        ],
      ),
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

/// 마지막 값만 카메라에 보낸다. 핀치와 슬라이더는 호출이 많다.
/// 앞의 호출이 끝나기 전에 들어온 값은 마지막 값만 남긴다.
class _LatestOnly {
  double? _pending;
  bool _busy = false;

  Future<void> send(double value, Future<void> Function(double) apply) async {
    _pending = value;
    if (_busy) return;
    _busy = true;
    try {
      while (_pending != null) {
        final target = _pending!;
        _pending = null;
        try {
          await apply(target);
        } on CameraException {
          // 카메라를 닫는 중이면 실패할 수 있다. 다음에 열 때 값을 다시 정한다.
          _pending = null;
        }
      }
    } finally {
      _busy = false;
    }
  }
}
