import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mangcut_bangji/data/guides.dart';
import 'package:mangcut_bangji/models/guide.dart';
import 'package:mangcut_bangji/models/photo_ratio.dart';
import 'package:mangcut_bangji/painting/filter_renderer.dart';
import 'package:mangcut_bangji/widgets/control_bar.dart';
import 'package:mangcut_bangji/widgets/lens_bar.dart';

void main() {
  test('비율 버튼은 4:3과 16:9를 번갈아 고른다', () {
    expect(PhotoRatio.r4x3.next, PhotoRatio.r16x9);
    expect(PhotoRatio.r16x9.next, PhotoRatio.r4x3);
  });

  group('ControlBar', () {
    late List<String> calls;

    Widget bar({Guide? guide, bool canFlip = true, bool canSwitch = true}) {
      return MaterialApp(
        home: Scaffold(
          body: ControlBar(
            ratio: PhotoRatio.r4x3,
            guide: guide,
            panelOpen: true,
            canFlip: canFlip,
            canSwitch: canSwitch,
            shutterEnabled: true,
            onRatio: () => calls.add('ratio'),
            onGuide: () => calls.add('guide'),
            onShutter: () => calls.add('shutter'),
            onFlip: () => calls.add('flip'),
            onSwitch: () => calls.add('switch'),
          ),
        ),
      );
    }

    setUp(() => calls = []);

    testWidgets('버튼 5개가 각자의 콜백을 부른다', (tester) async {
      await tester.pumpWidget(bar(guide: allGuides.first));
      await tester.tap(find.text('4:3'));
      await tester.tap(find.bySemanticsLabel('가이드 목록 접기'));
      await tester.tap(find.bySemanticsLabel('촬영'));
      await tester.tap(find.byTooltip('가이드 좌우 반전'));
      await tester.tap(find.byTooltip('카메라 전환'));
      expect(calls, ['ratio', 'guide', 'shutter', 'flip', 'switch']);
    });

    testWidgets('셔터는 조작 줄의 가운데에 있다', (tester) async {
      await tester.pumpWidget(bar(canFlip: false));
      final barRect = tester.getRect(find.byType(ControlBar));
      final shutter = tester.getCenter(find.bySemanticsLabel('촬영'));
      expect(shutter.dx, closeTo(barRect.center.dx, 0.5));
    });

    testWidgets('반전할 수 없으면 반전 버튼은 눌리지 않는다', (tester) async {
      await tester.pumpWidget(bar(canFlip: false, canSwitch: false));
      await tester.tap(find.byTooltip('가이드 좌우 반전'));
      await tester.tap(find.byTooltip('카메라 전환'));
      expect(calls, isEmpty);
    });
  });

  test('배율 표시는 렌즈에 따라 다르게 계산한다', () {
    expect(zoomLabel(CameraLensType.wide, 1), '1.0×');
    expect(zoomLabel(CameraLensType.wide, 2.34), '2.3×');
    expect(zoomLabel(CameraLensType.ultraWide, 1), '0.5×');
    expect(zoomLabel(CameraLensType.ultraWide, 1.5), '0.8×');
    expect(zoomLabel(CameraLensType.telephoto, 1.5), '망원 1.5×');
  });

  group('LensBar', () {
    Widget lensBar(
      List<CameraLensType> lenses,
      ValueChanged<CameraLensType> f,
    ) {
      return MaterialApp(
        home: Scaffold(
          body: LensBar(
            lenses: lenses,
            current: CameraLensType.wide,
            zoom: 2,
            onSelected: f,
          ),
        ),
      );
    }

    testWidgets('기기에 있는 렌즈만 표시하고 지금 렌즈에 배율을 표시한다', (tester) async {
      final picked = <CameraLensType>[];
      await tester.pumpWidget(
        lensBar(const [
          CameraLensType.ultraWide,
          CameraLensType.wide,
        ], picked.add),
      );
      expect(find.text('.5'), findsOneWidget);
      expect(find.text('2.0×'), findsOneWidget);
      expect(find.text('망원'), findsNothing);
      await tester.tap(find.text('.5'));
      await tester.tap(find.text('2.0×'));
      expect(picked, [CameraLensType.ultraWide, CameraLensType.wide]);
    });

    testWidgets('렌즈가 1개이면 배율만 표시한다', (tester) async {
      await tester.pumpWidget(lensBar(const [CameraLensType.wide], (_) {}));
      expect(find.text('2.0×'), findsOneWidget);
      expect(find.text('.5'), findsNothing);
    });
  });

  group('viewToSource', () {
    test('비율이 같으면 점이 그대로이다', () {
      const p = Offset(0.2, 0.7);
      final q = viewToSource(p, 0.75, 0.75);
      expect(q.dx, closeTo(p.dx, 1e-9));
      expect(q.dy, closeTo(p.dy, 1e-9));
    });

    test('3:4 영상을 9:16으로 자르면 가로 가장자리가 안쪽으로 온다', () {
      // 영상 너비 0.75 중 가운데 0.5625만 보인다. 양쪽 0.09375씩 잘린다.
      final left = viewToSource(const Offset(0, 0.5), 9 / 16, 3 / 4);
      final right = viewToSource(const Offset(1, 0.5), 9 / 16, 3 / 4);
      expect(left.dx, closeTo(0.125, 1e-9));
      expect(right.dx, closeTo(0.875, 1e-9));
      expect(left.dy, closeTo(0.5, 1e-9));
    });

    test('9:16 영상을 3:4로 자르면 세로 가장자리가 안쪽으로 온다', () {
      final top = viewToSource(const Offset(0.5, 0), 3 / 4, 9 / 16);
      final bottom = viewToSource(const Offset(0.5, 1), 3 / 4, 9 / 16);
      expect(top.dy, closeTo(0.125, 1e-9));
      expect(bottom.dy, closeTo(0.875, 1e-9));
      expect(top.dx, closeTo(0.5, 1e-9));
    });
  });
}
