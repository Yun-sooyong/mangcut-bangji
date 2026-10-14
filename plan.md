# 망컷방지 — 구현 계획 (plan.md)

- 작성일: 2026-10-14 (4차 개정), 2026-10-15 (9장 추가)
- 상태: **단계 1–5 완료. 단계 6 진행 중.** 9장(촬영 화면 개선)은 승인됨.
- 근거 문서: `research.md`
- 작성 규칙: `research.md`의 0장과 같습니다. 추정에는 **[추정]** 표시를 붙입니다.

## 변경 내역 (3차)

사용자의 지시 3개를 반영했습니다.

| 번호 | 지시 | 계획의 변경 |
|---|---|---|
| 1 | 촬영 화면에서 16:9와 4:3을 고릅니다. | 비율 선택 버튼을 추가합니다. 가이드가 두 비율에서 모두 맞게 그려지도록 가이드의 정의를 바꿉니다. (2.4, 3.1, 3.3, 5.4) |
| 2 | 빈티지 필터를 구분해서 표시합니다. 필터는 촬영 후에 적용합니다. | 촬영 화면에서 필터를 뺍니다. 결과 화면에 "기본"과 "빈티지" 2개 묶음을 표시합니다. (2.1, 2.3, 3.2, 5.3) |
| 3 | 필터 적용본과 원본을 함께 저장합니다. 스마트폰의 기본 저장소를 씁니다. | 저장할 때 사진 2장을 사진 보관함에 저장합니다. 별도 앨범은 만들지 않습니다. (2.5, 3.5, 5.5) |

지시 2의 결과로 위험 2개가 사라졌습니다.

- 미리보기의 색과 저장 사진의 색이 다를 위험
- 필터가 카메라 미리보기에 적용되지 않을 위험

## 0. 진행 상황 (2026-10-14)

| 단계 | 결과 |
|---|---|
| 1 | 완료. 초안을 이 계획에 맞게 고쳤습니다. `flutter analyze`에 문제가 없습니다. |
| 2 | 완료. 테스트 19개가 통과합니다. |
| 3 | 완료. 가이드 14종(두 비율)과 필터 12개의 그림을 확인했습니다. 그림은 `build/render_test/`에 있습니다. |
| 4 | 완료. iOS와 Android의 설정을 수정했습니다. |
| 5 | 완료. Android 에뮬레이터(Pixel 9 Pro)에서 전체 흐름을 확인했습니다. |
| 6 | 진행 중. iPhone 15 Pro(iOS 26.6.2)에 설치했습니다. 아래 "단계 6의 결과"를 보십시오. |
| 7 | 진행 중. 9장(촬영 화면 개선)을 구현합니다. |

### 단계 6의 결과 (2026-10-15)

Mac 환경은 다음과 같습니다.

| 항목 | 값 |
|---|---|
| macOS | 27.0.1 (Apple Silicon) |
| Xcode | 27.0 |
| Flutter | 3.47.7. Windows PC의 3.44.8보다 새 버전입니다. |
| CocoaPods | 1.17.0 |
| iPhone | iPhone 15 Pro, iOS 26.6.2 |

Mac에서 `flutter analyze`에 문제가 없습니다. 테스트 19개가 통과합니다.

Flutter 3.47이 파일 3개를 자동으로 고쳤습니다. 아직 커밋하지 않았습니다.

- `ios/Runner.xcodeproj/project.pbxproj`: 최소 iOS 버전을 13.0에서 15.0으로 올렸습니다. 사용자의 Team을 넣었습니다.
- `analysis_options.yaml`: `build`, `android`, `ios`를 분석에서 뺍니다.
- `pubspec.lock`: 테스트용 간접 패키지 4개의 버전이 올라갔습니다.

설치할 때 생긴 문제와 해결은 다음과 같습니다.

- 첫 빌드에서 Flutter가 Xcode 설정을 읽지 못했습니다. Xcode가 iPhone을 처음 준비하는 동안 60초 제한을 넘었습니다. 다시 실행하니 해결되었습니다.
- iPhone이 앱의 실행을 막았습니다. 사용자가 설정 → 일반 → VPN 및 기기 관리에서 개발자를 신뢰했습니다.

확인 항목(HANDOFF.md 5.2)의 결과는 다음과 같습니다.

| 번호 | 항목 | 결과 |
|---|---|---|
| 1 | 첫 실행에서 권한을 허용하면 미리보기가 바로 나옵니다. | 통과 |
| 2 | 저장한 사진이 똑바로 서 있습니다. | 통과 |
| 3 | 미리보기와 저장 사진의 영역이 같습니다. | 확인 전 |
| 4 | 전면 카메라 사진의 좌우가 미리보기와 같습니다. | 확인 전 |
| 5 | 저장 시간 | 확인 전 |
| 6 | 빈티지 필터의 색감과 입자 | 확인 전 |
| 7 | 권한을 거부했을 때의 안내 문구 | 확인 전 |
| 8 | 사진 보관함 권한 요청 문구 | 확인 전 |

사용자가 새로 말한 문제는 다음과 같습니다.

- 촬영 화면의 조작부를 접을 수 없습니다. 버튼이 여기저기 흩어져 있습니다.
- 카메라 줌이 안 됩니다.

두 문제의 계획은 9장에 있습니다.

9장의 구현 상황 (2026-10-15)은 다음과 같습니다.

| 순서 | 작업 | 결과 |
|---|---|---|
| A | 조작 줄, 가이드 패널 | 완료. 사용자가 iPhone에서 확인했습니다. |
| B | 렌즈 버튼, 핀치 줌 | 완료. 사용자가 iPhone에서 확인했습니다. |
| C | 초점과 노출 | 완료. 사용자가 iPhone에서 확인했습니다. |

`flutter analyze`에 문제가 없습니다. 테스트 29개가 통과합니다 (새 테스트 10개, `test/camera_controls_test.dart`).

C에서 새로 안 내용은 다음과 같습니다.

- `camera_avfoundation`은 초점 좌표를 세로 화면 기준(0–1)으로 받습니다. 그 다음 **기기의 실제 방향**(`UIDevice.current.orientation`)으로 센서 좌표로 바꿉니다 (`DefaultCamera.swift`의 `cgPoint`).
- 그래서 기기를 눕히면(화면이 하늘을 향함) 좌표를 바꾸지 않습니다. 이때 누른 곳과 초점의 위치가 다를 수 있습니다. **[추정]** 음식을 위에서 찍을 때 생길 수 있습니다.
- 전면 카메라의 미리보기는 거울처럼 보입니다. 전면에서 누른 곳과 초점의 위치가 맞는지 확인하지 못했습니다. **[미확인]**

C의 확인 결과는 다음과 같습니다.

- 누른 곳의 초점과 밝기 슬라이더가 동작합니다.
- 위에서 아래로 가까이 찍을 때, 1× 렌즈는 초점이 맞지 않습니다. 0.5× 렌즈는 접사도 초점이 맞습니다.
- 원인은 광각 렌즈의 최소 초점 거리입니다. **[추정]** iPhone 15 Pro의 광각 렌즈는 약 20cm보다 가까우면 초점이 맞지 않습니다. iPhone 기본 카메라는 이때 초광각 렌즈로 자동으로 바꿉니다(매크로). 이 앱은 렌즈를 자동으로 바꾸지 않습니다.
- 좌표가 어긋나는 문제인지는 따로 확인하지 않았습니다. 사용자는 0.5×로 찍을 수 있으므로 지금은 고치지 않습니다.
- 나중에 개선할 수 있는 것: 가까운 대상일 때 "0.5×로 바꾸면 초점이 맞습니다" 같은 안내를 보여 줍니다. MVP에서는 하지 않습니다.

단계 5에서 확인한 내용은 다음과 같습니다.

- 권한 요청, 4:3과 16:9의 전환, 장면과 가이드의 선택, 촬영, 필터 선택, 저장이 동작합니다.
- 갤러리에 사진 2장이 있습니다 (`mangcut_…_original.jpg`, `mangcut_…_faded.jpg`).
- 16:9로 찍은 사진은 720 × 1280입니다. 비율이 맞습니다. 가이드는 사진에 없습니다.
- 미리보기의 영역과 저장 사진의 영역이 같습니다.

단계 5에서 발견하고 고친 문제는 다음과 같습니다.

- 첫 실행 때 권한 창이 뜨면 앱이 카메라를 두 번 열었습니다. 그래서 카메라가 시작하지 않았습니다. 카메라를 여는 중에는 다시 열지 않도록 고쳤습니다. 이 문제는 iPhone에서도 생길 수 있었습니다.
- Android의 저장 권한 선언이 `camera` 패키지의 선언과 충돌했습니다. 값을 덮어쓰도록 고쳤습니다.
- 입자가 너무 거칠었습니다. 노이즈의 폭을 절반으로 줄였습니다.

확인하지 못한 내용은 다음과 같습니다.

- iPhone에서의 모든 동작 (5.10의 항목)
- 전면 카메라의 좌우 반전. 에뮬레이터에서 전면 카메라로 찍지 않았습니다.
- 권한을 거부했을 때의 화면
- 고해상도 사진의 저장 속도. 에뮬레이터의 사진은 720 × 1280입니다.
- 입자를 줄인 다음의 필터 그림. 테스트는 통과했지만 눈으로 다시 보지 않았습니다.

## 1. 확정된 조건

| 항목 | 결정 |
|---|---|
| 대상 플랫폼 | iOS |
| 프레임워크 | Flutter 3.44.8, Dart 3.12.2 |
| 빌드 방법 | A: 이 PC에서 개발합니다. Android로 먼저 확인합니다. iOS 빌드는 Mac에서 합니다. |
| 가이드 분류 | 장면별 |
| 사진 비율 | 사용자가 4:3과 16:9 중에서 고릅니다. |
| 필터 적용 시점 | 촬영 후 |
| 필터 표시 | "기본"과 "빈티지"를 구분합니다. |
| 저장 | 필터 적용본과 원본을 함께 저장합니다. 사진 보관함을 씁니다. |
| 저장하는 원본 | 자른 원본. 고른 비율로 자르고 필터만 없는 사진입니다. |
| 테스트 기기 | iPhone만 있습니다. Android 실제 기기는 없습니다. |
| 초안 | 유지 |
| MVP 제외 | 로그인, SNS, AI, 동영상, 수동 보정 슬라이더 |

확인한 환경: 이 PC에는 Android 에뮬레이터가 2개 있습니다 (`Pixel_9_Pro`, `Medium_Tablet`).

## 2. MVP의 범위

### 2.1 화면과 흐름

1. **촬영 화면**: 미리보기(필터 없음), 가이드, 비율 버튼, 장면 탭, 가이드 목록, 셔터 버튼, 카메라 전환 버튼, 가이드 좌우 반전 버튼
2. **결과 화면**: 촬영한 사진, 필터 묶음 탭(기본, 빈티지), 필터 목록, 저장 버튼, 다시 찍기 버튼

흐름은 다음과 같습니다.

1. 사용자가 앱을 켭니다. 앱이 카메라 권한을 요청합니다.
2. 사용자가 비율을 고릅니다 (4:3 또는 16:9). 처음 값은 4:3입니다.
3. 사용자가 장면을 고릅니다. 앱이 그 장면의 첫 가이드를 표시합니다.
4. 사용자가 가이드를 고릅니다.
5. 사용자가 셔터 버튼을 누릅니다.
6. 앱이 결과 화면을 표시합니다. 처음 필터는 "원본"입니다.
7. 사용자가 필터를 고릅니다.
8. 사용자가 저장 버튼을 누릅니다. 앱이 필터 적용본과 원본을 사진 보관함에 저장합니다.

가이드는 저장하는 사진에 포함하지 않습니다.

### 2.2 장면과 가이드

장면 5개, 가이드 14종입니다. 2차 계획과 같습니다.

| 장면 | 가이드 |
|---|---|
| 인물 | 삼분할, 황금 나선, 중앙, 여백 |
| 풍경 | 삼분할, 황금 분할, 대각선, S자, 여백 |
| 건축·도시 | 대칭, 프레임 속 프레임, 삼각형, 반복 |
| 음식·카페 | 중앙, 삼분할, 대각선, 삼각형 |
| 길·골목 | 소실점, 유도선, 대칭, V자 |

### 2.3 필터

필터는 2개 묶음입니다. 이름은 임시 이름입니다. 값은 실제 기기에서 조정합니다.

**기본 (5개)**: 색만 바꿉니다. 입자와 비네팅은 없습니다.

| id | 이름 | 채도 | 채널 배율 (R, G, B) | 대비 | 밝기 |
|---|---|---|---|---|---|
| `original` | 원본 | – | – | – | – |
| `vivid` | 선명하게 | 1.20 | – | 1.10 | – |
| `warm` | 따뜻하게 | – | 1.06, 1.00, 0.92 | – | – |
| `cool` | 차갑게 | – | 0.94, 1.00, 1.06 | – | – |
| `mono` | 흑백 | 0 | – | 1.05 | – |

**빈티지 (7개)**: 색을 바꾸고 입자와 비네팅을 더합니다.

| id | 이름 | 채도 | 채널 배율 (R, G, B) | 대비 | 바램 | 밝기 | 입자 | 비네팅 |
|---|---|---|---|---|---|---|---|---|
| `warm_film` | 따뜻한 필름 | 0.85 | 1.08, 1.00, 0.88 | 0.95 | 0.04 | – | 0.18 | 0.20 |
| `faded` | 바랜 사진 | 0.60 | 1.03, 1.00, 0.94 | 0.82 | 0.10 | – | 0.22 | 0.25 |
| `sunset` | 노을빛 | 1.05 | 1.14, 1.00, 0.80 | – | – | +0.03 | 0.12 | 0.18 |
| `cool_film` | 차가운 필름 | 0.85 | 0.92, 1.02, 1.08 | 0.92 | 0.05 | – | 0.15 | 0.15 |
| `vivid_slide` | 진한 슬라이드 | 1.35 | – | 1.15 | – | – | 0.08 | 0.22 |
| `instant` | 즉석 사진 | 0.90 | 1.00, 1.04, 0.95 | 0.85 | 0.08 | +0.05 | 0.10 | 0.30 |
| `mono_film` | 흑백 필름 | 0 | – | 1.15 | – | – | 0.30 | 0.25 |

### 2.4 사진 비율

- 화면 방향은 세로 고정입니다. 따라서 4:3은 세로 3:4이고, 16:9는 세로 9:16입니다.
- 비율 버튼은 미리보기의 위쪽에 있습니다. 누르면 두 값이 바뀝니다.
- 앱은 미리보기와 저장 사진을 모두 고른 비율로 자릅니다.
- 화면 배치는 다음과 같습니다.
  - 4:3: 미리보기가 위에 있습니다. 조작부가 그 아래에 있습니다. 겹치지 않습니다.
  - 16:9: 미리보기가 화면의 높이를 거의 다 씁니다. 조작부는 미리보기의 아래쪽 위에 반투명하게 겹칩니다.

### 2.5 저장

- 저장 위치는 **사진 보관함**입니다. iOS에서는 사진 앱이고, Android에서는 갤러리입니다. 별도 앨범은 만들지 않습니다.
- 저장 버튼을 누르면 앱이 사진 2장을 저장합니다.
  1. 원본: 고른 비율로 자른 사진. 필터가 없습니다.
  2. 필터 적용본
- 사용자가 "원본" 필터를 고르면 두 사진이 같습니다. 이때는 1장만 저장합니다.
- 원본은 필터 적용본과 구도가 같습니다. 원본에는 EXIF(촬영 시간, 기종)가 없습니다. 이유는 5.5에 있습니다.

### 2.6 그 밖의 기본값

| 항목 | 기본값 |
|---|---|
| 저장 형식 | JPEG, 품질 92 |
| 저장 해상도 | 긴 변 최대 4032픽셀 |
| 가이드의 선 | 흰색 1.5pt + 반투명 검은 선 |
| 언어 | 한국어 |
| 앱 식별자 | `com.mangcut.mangcutBangji` (임시) |

## 3. 접근 방식

### 3.1 가이드: 비율 좌표의 도형 목록, 화면 비율에 따라 생성

가이드 1개를 "도형의 목록"으로 정의합니다. 좌표는 화면 크기에 대한 비율(0.0–1.0)입니다.

비율 좌표의 문제: 원을 비율 좌표로 정의하면 3:4에서는 원이고 9:16에서는 세로로 긴 타원이 됩니다. 그래서 가이드는 화면 비율을 받아서 도형을 만듭니다.

```dart
// lib/models/guide.dart
sealed class GuideShape {
  const GuideShape();
  Iterable<Offset> get points; // 좌표 범위 검사에 쓴다
}
class GuideLine extends GuideShape { final Offset a, b; ... }
class GuideRect extends GuideShape { final Rect rect; final double radius; ... }
class GuideOval extends GuideShape { final Rect rect; ... }
class GuidePath extends GuideShape { final List<Offset> points; final bool closed; ... }

class Guide {
  final String id;
  final String name;
  final bool flippable;

  /// [aspect]는 화면의 너비 ÷ 높이이다. (3:4는 0.75, 9:16은 0.5625)
  final List<GuideShape> Function(double aspect) build;
}
```

```dart
// lib/data/guides.dart
// 비율과 무관한 가이드
final thirds = Guide(id: 'thirds', name: '삼분할', build: (_) => _grid(1 / 3, 2 / 3));

// 비율에 따라 높이를 계산하는 가이드. 어느 비율에서도 원으로 보인다.
final center = Guide(
  id: 'center',
  name: '중앙',
  build: (aspect) {
    const w = 0.56;
    final h = w * aspect; // 화면에서 너비와 높이의 실제 길이가 같아진다
    return [GuideOval(Rect.fromCenter(center: const Offset(0.5, 0.5), width: w, height: h))];
  },
);
```

비율에 따라 계산하는 가이드는 3종입니다: 중앙(원), 프레임 속 프레임(아치의 반원), 유도선(타원). 나머지 11종은 비율과 무관합니다. 황금 나선은 화면에 맞춰 늘립니다.

그리기는 `CustomPainter` 1개가 담당합니다.

```dart
// lib/painting/guide_painter.dart
class GuidePainter extends CustomPainter {
  const GuidePainter(this.guide, {this.flipped = false, this.strokeWidth = 1.5, ...});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (final shape in guide.build(size.width / size.height)) {
      switch (shape) {
        case GuideLine(:final a, :final b):
          path..moveTo(a.dx * size.width, a.dy * size.height)
              ..lineTo(b.dx * size.width, b.dy * size.height);
        case GuideRect(:final rect, :final radius): ...
        case GuideOval(:final rect): ...
        case GuidePath(:final points, :final closed): ...
      }
    }
    if (flipped && guide.flippable) {
      canvas..translate(size.width, 0)..scale(-1, 1);
    }
    canvas..drawPath(path, shadow)..drawPath(path, line); // 어두운 선, 그 위에 흰 선
  }
}
```

같은 `GuidePainter`를 가이드 목록의 작은 그림에도 씁니다.

### 3.2 필터: 색 행렬 + 입자 + 비네팅, 묶음으로 구분

```dart
// lib/models/photo_filter.dart
enum FilterCategory {
  basic('기본'),
  vintage('빈티지');

  const FilterCategory(this.label);
  final String label;
}

class PhotoFilter {
  final String id;
  final String name;
  final FilterCategory category;
  final ColorMatrix matrix; // 4×5 색 행렬
  final double grain;       // 입자의 강도 0–1
  final double vignette;    // 가장자리 어둡게 0–1
}
```

```dart
// lib/data/filters.dart
PhotoFilter(
  id: 'warm_film',
  name: '따뜻한 필름',
  category: FilterCategory.vintage,
  matrix: ColorMatrix.saturation(0.85)
      .then(ColorMatrix.gains(1.08, 1.0, 0.88))
      .then(ColorMatrix.contrast(0.95))
      .then(ColorMatrix.fade(0.04)),
  grain: 0.18,
  vignette: 0.2,
),
```

결과 화면은 묶음 탭과 필터 목록을 표시합니다.

```dart
// lib/widgets/filter_picker.dart
Column(children: [
  SegmentedButton<FilterCategory>(
    segments: [for (final c in FilterCategory.values) ButtonSegment(value: c, label: Text(c.label))],
    selected: {category},
    onSelectionChanged: (s) => onCategoryChanged(s.first),
  ),
  // 고른 묶음의 필터만 가로 목록으로 표시한다
  ListView(scrollDirection: Axis.horizontal, children: [
    for (final f in filters.where((f) => f.category == category)) ChoiceChip(...),
  ]),
])
```

필터는 결과 화면에서만 적용합니다. 화면에 보여 주는 경로와 저장하는 경로가 같은 값과 같은 그리기 함수를 씁니다.

```dart
// lib/painting/filter_renderer.dart
// 입자와 비네팅을 그린다. 화면 표시와 저장이 함께 쓴다.
void paintFilterOverlays(Canvas canvas, Size size, PhotoFilter filter, ui.Image? noise) { ... }

// 저장용: 기준 이미지에 필터를 적용한 새 이미지를 만든다.
Future<ui.Image> renderFiltered(ui.Image source, PhotoFilter filter, ui.Image? noise) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawImage(source, Offset.zero,
      Paint()..colorFilter = ColorFilter.matrix(filter.matrix.values));
  paintFilterOverlays(canvas, size, filter, noise);
  return recorder.endRecording().toImage(source.width, source.height);
}
```

```dart
// lib/widgets/filtered_view.dart — 화면 표시용
Stack(fit: StackFit.expand, children: [
  ColorFiltered(
    colorFilter: ColorFilter.matrix(filter.matrix.values),
    child: RawImage(image: image, fit: BoxFit.cover),
  ),
  IgnorePointer(child: CustomPaint(painter: FilterOverlayPainter(filter, noise))),
])
```

### 3.3 사진 비율: 미리보기와 저장 사진을 같은 영역으로 자르기

```dart
// lib/models/photo_ratio.dart
enum PhotoRatio {
  r4x3('4:3', 3 / 4),
  r16x9('16:9', 9 / 16);

  const PhotoRatio(this.label, this.aspect);
  final String label;
  final double aspect; // 세로 화면에서 너비 ÷ 높이
}
```

카메라의 미리보기 비율은 기기와 해상도 설정에 따라 다릅니다. `camera` 패키지는 비율을 직접 고르는 기능이 없습니다. 그래서 두 경로에서 모두 가운데를 고른 비율로 자릅니다.

```dart
// lib/screens/camera_screen.dart — 미리보기
AspectRatio(
  aspectRatio: _ratio.aspect,
  child: ClipRect(
    child: FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: previewSize.height, // previewSize는 가로 기준이다
        height: previewSize.width,
        child: CameraPreview(controller),
      ),
    ),
  ),
)
```

```dart
// lib/painting/filter_renderer.dart — 촬영한 사진
Future<ui.Image> prepareCapture(Uint8List bytes, {required double aspect, bool mirror = false}) async {
  final src = (await (await ui.instantiateImageCodec(bytes)).getNextFrame()).image;
  final crop = centerCrop(Size(src.width.toDouble(), src.height.toDouble()), aspect);
  // crop 영역을 새 캔버스에 그린다. mirror가 참이면 좌우를 뒤집는다.
  // 긴 변이 4032픽셀보다 길면 줄인다.
}
```

### 3.4 촬영 화면의 배치

```dart
// lib/screens/camera_screen.dart
Stack(children: [
  Align(alignment: Alignment.topCenter, child: /* 미리보기 + 가이드 */),
  Align(
    alignment: Alignment.bottomCenter,
    child: ColoredBox(
      color: Colors.black54, // 16:9에서는 미리보기 위에 겹친다
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SceneTabs(...), GuidePicker(...), _ShutterButton(...),
      ]),
    ),
  ),
])
```

### 3.5 촬영과 저장

```dart
// lib/screens/camera_screen.dart
final controller = CameraController(camera, ResolutionPreset.max, enableAudio: false);
await controller.initialize();
await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);

final file = await controller.takePicture();
final image = await prepareCapture(
  await file.readAsBytes(),
  aspect: _ratio.aspect,
  mirror: camera.lensDirection == CameraLensDirection.front,
);
Navigator.of(context).push(MaterialPageRoute(
  builder: (_) => ResultScreen(image: image, noise: widget.noise),
));
```

```dart
// lib/screens/result_screen.dart
Future<void> _save() async {
  if (!await Gal.hasAccess()) await Gal.requestAccess();
  final stamp = DateTime.now().millisecondsSinceEpoch;

  // 1. 원본 (필터 없음)
  await Gal.putImageBytes(await encodeJpeg(widget.image), name: 'mangcut_${stamp}_original');

  // 2. 필터 적용본. 원본 필터를 고르면 건너뛴다.
  if (_filter != original) {
    final rendered = await renderFiltered(widget.image, _filter, widget.noise);
    await Gal.putImageBytes(await encodeJpeg(rendered), name: 'mangcut_${stamp}_${_filter.id}');
    rendered.dispose();
  }
}
```

원본을 먼저 저장합니다. 두 번째 저장이 실패해도 원본은 남습니다.

### 3.6 상태 관리

상태 관리 패키지를 쓰지 않습니다.

```dart
// 촬영 화면
PhotoRatio _ratio;    // 선택한 비율
Scene _scene;         // 선택한 장면
Guide? _guide;        // 선택한 가이드. null은 "없음"
bool _flipped;        // 가이드 좌우 반전

// 결과 화면
FilterCategory _category; // 선택한 필터 묶음
PhotoFilter _filter;      // 선택한 필터
```

앱이 백그라운드로 가면 카메라를 닫습니다. 앱이 돌아오면 카메라를 다시 엽니다.

## 4. 파일 목록

상태의 뜻: **초안** = 이미 작성했고 검증하지 않음. **미작성** = 아직 없음. **수정 필요** = `flutter create`가 만든 파일을 고쳐야 함.

### 4.1 앱 코드

| 경로 | 역할 | 상태 | 3차 계획에 따른 변경 |
|---|---|---|---|
| `lib/main.dart` | 세로 고정, 노이즈 이미지 생성, 앱 시작 | 초안 | 없음 |
| `lib/app.dart` | `MaterialApp`, 어두운 테마 | 초안 | 없음 |
| `lib/models/guide.dart` | `GuideShape`, `Guide` | 초안 | `shapes`를 `build(aspect)`로 변경 |
| `lib/models/scene.dart` | `Scene` | 초안 | 없음 |
| `lib/models/photo_filter.dart` | `ColorMatrix`, `PhotoFilter` | 초안 | `FilterCategory` 추가 |
| `lib/models/photo_ratio.dart` | `PhotoRatio` | 미작성 | 새 파일 |
| `lib/data/guides.dart` | 가이드 14종, 곡선 생성 함수 | 초안 | 모든 가이드를 `build` 형식으로 변경. 3종은 비율로 계산 |
| `lib/data/scenes.dart` | 장면 5개 | 초안 | 없음 |
| `lib/data/filters.dart` | 필터 12개 | 초안 | 기본 4개 추가. 모든 필터에 묶음 지정 |
| `lib/painting/guide_painter.dart` | `GuidePainter` | 초안 | `guide.build(aspect)` 호출 |
| `lib/painting/filter_renderer.dart` | 입자·비네팅, 자르기, 필터 적용, JPEG 인코딩 | 초안 | 고정 비율 상수 삭제. `prepareCapture`에 `aspect` 추가 |
| `lib/widgets/filtered_view.dart` | 자식 위젯에 필터 적용 | 초안 | 없음 |
| `lib/widgets/scene_tabs.dart` | 장면 탭 | 초안 | 없음 |
| `lib/widgets/guide_picker.dart` | 가이드 목록 | 초안 | 없음 |
| `lib/widgets/filter_picker.dart` | 필터 묶음 탭과 필터 목록 | 초안 | 묶음 탭 추가 |
| `lib/screens/camera_screen.dart` | 촬영 화면 | 초안 | 필터 삭제. 비율 버튼 추가. 배치를 `Stack`으로 변경 |
| `lib/screens/result_screen.dart` | 결과 화면 | 초안 | 사진의 비율을 이미지에서 계산. 2장 저장 |

### 4.2 테스트

| 경로 | 검증하는 내용 | 상태 |
|---|---|---|
| `test/widget_test.dart` | 기본 생성 파일. 삭제합니다. | 수정 필요 (지금 깨져 있음) |
| `test/data_test.dart` | 가이드 14종. 두 비율에서 좌표가 0–1 범위. 장면 5개. 필터 12개와 묶음. | 미작성 |
| `test/photo_filter_test.dart` | 색 행렬의 계산 (채도, 대비, 바램, 이어 붙이기) | 미작성 |
| `test/render_test.dart` | 두 비율의 자르기. 원본 필터는 픽셀을 바꾸지 않음. JPEG 인코딩. 가이드(두 비율)와 필터의 그림을 `build/render_test/`에 PNG로 저장 | 미작성 |

### 4.3 설정

| 경로 | 수정 내용 | 상태 |
|---|---|---|
| `ios/Runner/Info.plist` | `NSCameraUsageDescription`, `NSPhotoLibraryAddUsageDescription` 추가. 표시 이름을 "망컷방지"로 변경. 화면 방향을 세로만 남김. | 수정 필요 |
| `android/app/src/main/AndroidManifest.xml` | `android:label`을 "망컷방지"로 변경. Android 9 이하용 저장 권한 추가. | 수정 필요 |
| `pubspec.yaml` | `description` 수정. 패키지 3개는 이미 추가함. | 수정 필요 |
| `CLAUDE.md` | 서브에이전트 모델 규칙, 명령, 구조 | 작성함. "미리보기와 저장 사진" 규칙을 3차 계획에 맞게 수정 필요 |
| `README.md` | 기본 생성 파일. 프로젝트 설명으로 교체. | 수정 필요 |

## 5. 트레이드오프

### 5.1 필터: 색 행렬 대 셰이더(LUT)

| | 색 행렬 (선택) | 프래그먼트 셰이더 + LUT |
|---|---|---|
| 표현력 | 모든 색에 같은 선형 계산. 톤별 색 변경은 못 합니다. | 거의 모든 색감을 표현합니다. |
| 구현 | Flutter 기본 기능. 코드가 짧습니다. | GLSL 코드와 LUT 이미지가 필요합니다. |
| 필터 추가 | 숫자 몇 개 | LUT 이미지 1장. 외부 도구가 필요합니다. |
| 위험 | 빈티지 느낌이 약할 수 있습니다. | 구현에 시간이 듭니다. |

필터를 촬영 후에만 적용하므로 셰이더로 바꾸기가 더 쉬워졌습니다. 카메라 미리보기와 관계가 없기 때문입니다. `PhotoFilter`와 `filter_renderer.dart`의 내부만 바꿉니다.

### 5.2 가이드: 코드로 그리기 대 이미지(SVG, PNG)

| | 코드로 그리기 (선택) | 이미지 |
|---|---|---|
| 화면 비율 | 4:3과 16:9에 모두 맞습니다. 원도 원으로 유지합니다. | 비율마다 이미지가 필요하거나 늘어납니다. |
| 선의 굵기 | 화면 크기와 무관하게 일정합니다. | 크기를 바꾸면 굵기도 바뀝니다. |
| 가이드 추가 | 좌표를 직접 씁니다. 복잡한 그림은 어렵습니다. | 디자인 도구로 그립니다. |
| 저작권 | 직접 정의한 도형이므로 문제가 없습니다. | 출처를 관리해야 합니다. |

비율을 2개 지원하므로 코드로 그리는 방식의 장점이 더 커졌습니다.

### 5.3 필터 적용 시점: 촬영 후만 (변경됨)

| | 촬영 후만 (선택) | 미리보기 + 촬영 후 |
|---|---|---|
| 사용 경험 | 찍은 다음에 필터를 고릅니다. | 찍기 전에 결과를 봅니다. |
| 구현 | 경로가 1개입니다. 단순합니다. | 두 경로의 색을 맞춰야 합니다. |
| 위험 | 없음 | 기기에 따라 미리보기와 사진의 색이 다를 수 있습니다. |
| 촬영 화면 | 가이드에만 집중합니다. 조작부가 줄어듭니다. | 조작부가 많습니다. |

나중에 미리보기 필터를 추가할 수 있습니다. `FilteredView`가 어떤 위젯에도 필터를 적용할 수 있기 때문입니다.

### 5.4 사진 비율: 가운데 자르기 대 카메라 해상도 변경

| | 가운데 자르기 (선택) | 비율마다 카메라 해상도를 바꿈 |
|---|---|---|
| 구현 | 카메라 설정은 1개입니다. 자르는 영역만 바꿉니다. | 비율을 바꿀 때마다 카메라를 다시 엽니다. |
| 비율 전환 | 즉시 바뀝니다. | 약 1초 동안 화면이 멈춥니다. **[추정]** |
| 화질 | 한 비율은 센서 영상의 일부를 버립니다. 그 비율의 해상도가 낮아집니다. | 두 비율 모두 카메라가 주는 최대 해상도입니다. |
| 기기 차이 | 기기가 주는 비율과 무관하게 동작합니다. | `camera` 패키지가 비율을 직접 고르는 기능을 주지 않습니다. 기기마다 결과가 다릅니다. |

화질 손실의 예 **[추정]**: 카메라가 16:9(3840 × 2160)를 주면 4:3 사진은 2880 × 2160입니다. 카메라가 4:3(4032 × 3024)을 주면 16:9 사진은 4032 × 2268입니다. 어느 쪽인지는 실제 기기에서 확인합니다.

16:9의 화면 배치에도 선택이 있습니다.

| | 조작부를 반투명하게 겹침 (선택) | 미리보기를 줄여서 겹치지 않게 함 |
|---|---|---|
| 미리보기의 크기 | 화면 너비를 다 씁니다. | 너비가 약 80%로 줄어듭니다. |
| 구도 확인 | 사진의 아래쪽 약 20%가 조작부 뒤에 있습니다. 반투명이라서 보입니다. | 사진 전체가 선명하게 보입니다. |

실제 기기에서 불편하면 두 번째 방식으로 바꿉니다.

### 5.5 저장하는 원본의 정의

| | 자른 원본 (선택) | 카메라 파일 그대로 |
|---|---|---|
| 내용 | 고른 비율로 자른 사진. 필터만 없습니다. | 카메라가 만든 JPEG 파일. 자르지 않습니다. |
| 구도 | 필터 적용본과 같습니다. 가이드로 맞춘 구도가 그대로 있습니다. | 고른 비율과 다를 수 있습니다. 가이드로 맞춘 구도와 다릅니다. |
| 화질 | JPEG를 한 번 다시 인코딩합니다. 손실이 아주 조금 있습니다. | 손실이 없습니다. 센서 영상 전체가 있습니다. |
| EXIF (촬영 시간, 기종) | 사라집니다. | 남습니다. |
| 전면 카메라 | 미리보기와 같은 좌우입니다. | 미리보기와 좌우가 반대입니다. |
| 저장 속도 | 인코딩을 2번 합니다. 느립니다. | 인코딩을 1번 합니다. 빠릅니다. |

선택 이유: 이 앱의 목적은 구도입니다. 원본도 사용자가 맞춘 구도와 같아야 합니다.

### 5.6 원본과 필터 적용본을 함께 저장 (변경됨)

| | 2장 저장 (선택) | 필터 적용본만 저장 |
|---|---|---|
| 저장 공간 | 사진 1번에 2장 | 1장 |
| 다시 편집 | 원본으로 다른 앱에서 편집할 수 있습니다. | 못 합니다. |
| 사진 보관함 | 비슷한 사진이 2장씩 쌓입니다. | 깔끔합니다. |

대응: "원본" 필터를 고르면 1장만 저장합니다.

### 5.7 저장 위치: 사진 보관함 대 앱 전용 앨범 대 앱 내부

| | 사진 보관함 (선택) | 앱 전용 앨범 | 앱 내부 폴더 |
|---|---|---|---|
| 사용자가 찾기 | 사진 앱에서 바로 보입니다. | 사진 앱의 앨범에서 보입니다. | 이 앱에서만 보입니다. |
| 권한 (iOS) | "추가만" 권한 | 전체 접근 권한이 필요합니다. | 필요 없음 |
| 구현 | 단순합니다. | 단순합니다. | 앱 안에 사진 목록 화면이 필요합니다. |

### 5.8 JPEG 인코딩: `image` 패키지 대 플랫폼 기본 기능

| | `image` 패키지 (선택) | 플랫폼 코드 (Swift, Kotlin) |
|---|---|---|
| 속도 | 느립니다. 12MP 사진 1장에 수 초가 걸릴 수 있습니다. **[추정]** 2장을 저장하므로 시간이 2배입니다. | 빠릅니다. |
| 구현 | Dart 코드만 씁니다. iOS와 Android가 같습니다. | 플랫폼별 코드를 작성합니다. Mac 없이는 iOS 쪽을 검증할 수 없습니다. |

대응: 인코딩을 별도 isolate에서 실행합니다. 저장 버튼에 진행 표시를 넣습니다. 너무 느리면 저장 해상도를 낮추거나 플랫폼 코드로 바꿉니다.

### 5.9 상태 관리: `setState` 대 Riverpod, Bloc

`setState`를 씁니다. 화면이 2개이고 화면 사이에 넘기는 값이 사진 1장입니다.

### 5.10 Android 에뮬레이터로 먼저 확인하는 방법의 한계

- Android 실제 기기가 없습니다. 이 PC에서는 에뮬레이터로만 확인합니다.
- 에뮬레이터에서 맞아도 iPhone에서 다를 수 있는 항목이 있습니다.
  - 카메라가 주는 미리보기의 비율과 사진의 비율
  - 사진의 회전 방향 (EXIF)
  - 전면 카메라의 좌우 반전
  - 권한 요청의 문구와 동작
- 에뮬레이터의 카메라는 가상 장면입니다. 색감, 구도의 느낌, 저장 속도는 iPhone에서만 판단할 수 있습니다.
- 따라서 iPhone 확인(단계 6)은 생략할 수 없습니다. 실제 검증의 대부분은 단계 6에서 합니다.
- iPhone에 앱을 설치하려면 Mac(Xcode)이 필요합니다. Mac이 없으면 클라우드 빌드와 TestFlight를 써야 합니다. 이때는 Apple Developer 계정(연 99달러)이 필요합니다. 8장의 D1을 보십시오.

## 6. 작업 단계

각 단계가 끝나면 확인 방법으로 검증합니다. 문제가 있으면 다음 단계로 가지 않습니다.

| 단계 | 작업 | 확인 방법 |
|---|---|---|
| 1 | 초안을 3차 계획에 맞게 고칩니다 (4.1의 변경 열). `test/widget_test.dart`를 삭제합니다. | `flutter analyze`에 문제가 없습니다. |
| 2 | 테스트 3개를 작성합니다 (4.2). | `flutter test`가 통과합니다. |
| 3 | 가이드 14종(두 비율)과 필터 12개의 그림을 PNG로 만듭니다. | 그림을 `research.md`의 모양과 비교합니다. 그림을 사용자에게 보여 줍니다. |
| 4 | 설정 파일을 수정합니다 (4.3). | Android 에뮬레이터에서 앱이 시작합니다. 권한 요청이 나옵니다. |
| 5 | 에뮬레이터에서 전체 흐름을 확인합니다. | 비율 전환, 가이드 선택, 촬영, 필터 선택, 저장이 동작합니다. 갤러리에 사진 2장이 있습니다. 사진의 비율이 맞습니다. 가이드가 사진에 없습니다. |
| 6 | iOS 빌드를 하고 iPhone에서 확인합니다. | 미리보기와 사진의 영역이 같습니다. 사진의 방향이 맞습니다. 5.10의 항목을 모두 확인합니다. |
| 7 | 발견한 문제를 수정합니다. 필터의 값을 조정합니다. | 문제 목록을 만들고 하나씩 수정합니다. |

단계 1–5는 이 PC에서 할 수 있습니다. 단계 6은 사용자의 iPhone과 Mac(또는 클라우드 빌드)이 필요합니다.

## 7. 미리 알고 있는 위험

| 위험 | 대응 |
|---|---|
| 카메라가 주는 미리보기의 비율과 사진의 비율이 다릅니다. 그러면 가이드의 위치가 사진과 맞지 않습니다. | 두 경로에서 가운데를 같은 비율로 자릅니다. 격자가 있는 대상을 찍어서 검증합니다. 다르면 해상도 설정을 바꿉니다. |
| 사진이 옆으로 누워서 나옵니다. | 디코더가 EXIF 회전을 적용하는지 기기에서 확인합니다. 적용하지 않으면 직접 회전합니다. |
| 전면 카메라의 사진이 미리보기와 좌우가 다릅니다. | 전면 카메라일 때 사진을 좌우로 뒤집습니다. 기기에서 확인합니다. |
| 16:9에서 조작부가 미리보기의 아래쪽을 가립니다. | 반투명으로 겹칩니다. 불편하면 미리보기를 줄입니다 (5.4). |
| 작은 화면에서 4:3 미리보기와 조작부가 겹칩니다. | 조작부의 높이를 줄이거나 16:9와 같이 겹칩니다. 기기에서 확인합니다. |
| 색 행렬만으로는 빈티지 느낌이 약합니다. | 입자와 비네팅으로 보완합니다. 부족하면 셰이더(LUT)로 바꿉니다. |
| 사진 2장의 인코딩이 느립니다. | 별도 isolate, 진행 표시. 필요하면 해상도를 낮추거나 플랫폼 코드로 바꿉니다. |
| App Store 심사 | MVP 범위 밖입니다. 배포 단계에서 따로 계획합니다. |

## 8. 결정된 내용과 남은 질문

### 8.1 결정된 내용

| 내용 | 결정 |
|---|---|
| 초안의 처리 | 유지 |
| 저장 위치 | 사진 보관함 |
| 저장하는 원본 | 자른 원본 |
| 기본 필터 5개의 구성 | 제안대로 진행 |
| 16:9의 화면 배치 | 조작부를 반투명하게 겹침 |
| 테스트 기기 | iPhone. Android는 에뮬레이터만 씁니다. |
| iOS 빌드 | 사용자의 Mac에서 합니다. |

### 8.2 남은 질문

없습니다. Mac이 있으므로 단계 6은 Mac에서 `flutter build ios`로 빌드하고 Xcode로 iPhone에 설치합니다. 클라우드 빌드는 필요하지 않습니다.

### 8.3 승인

"승인"이라고 답해 주십시오. 그 전에는 코드를 작성하지 않습니다.

## 9. 촬영 화면 개선 (단계 7의 첫 작업)

- 작성일: 2026-10-15 (2차)
- 상태: **승인됨 (2026-10-15).** 조리개 대신 밝기(노출) 조절로 진행합니다.
- 근거: iPhone에서 사용자가 말한 문제 2개 (0장의 "단계 6의 결과")

### 9.1 사용자의 결정

| 질문 | 결정 |
|---|---|
| 장면 탭과 가이드 목록을 어떻게 접습니까? | 가이드 버튼으로 접고 펼칩니다. |
| 흩어진 버튼을 어디에 모읍니까? | 셔터가 있는 아래쪽 줄에 모읍니다. |
| 가이드 패널의 처음 상태 | **펼친 상태**로 시작합니다. |
| 줌 | **렌즈 버튼과 핀치 줌을 모두** 넣습니다. |
| 조리개 | 가능하면 넣습니다. → iPhone에서는 불가능합니다. 대신 노출 조절을 제안합니다 (9.4). |

### 9.2 화면 배치

```
┌─────────────────────────┐
│                         │
│   미리보기 + 가이드       │  ← 누르면 초점과 노출을 맞춤 (9.4)
│                    ☀    │  ← 노출 슬라이더 (누른 다음 3초 동안)
│                         │
│     (.5)  (1×)  (망원)   │  ← 렌즈 버튼 + 줌 배율 (9.3)
├─────────────────────────┤
│ 인물 풍경 건축·도시 …     │  ┐ 가이드 패널
│ [없음][□][□][□][□]       │  ┘ (처음에는 펼침)
│ [4:3] [가이드] (●) [⇋] [↻] │  ← 조작 줄 (항상 보임)
└─────────────────────────┘
```

조작 줄에는 5개 칸이 있습니다. 셔터는 항상 가운데에 있습니다.

| 칸 | 요소 | 동작 |
|---|---|---|
| 1 | 비율 버튼 | 지금 비율("4:3" 또는 "16:9")을 글자로 표시합니다. 누르면 다른 비율로 바뀝니다. |
| 2 | 가이드 버튼 | 지금 가이드의 작은 그림을 표시합니다. 누르면 가이드 패널을 접거나 펼칩니다. 펼쳐져 있으면 노란색 테두리를 그립니다. |
| 3 | 셔터 | 지금과 같습니다. |
| 4 | 가이드 반전 버튼 | 반전할 수 있는 가이드일 때만 누를 수 있습니다. 그 밖에는 흐리게 표시합니다. 칸은 비우지 않습니다. 셔터의 위치를 유지하기 위해서입니다. |
| 5 | 카메라 전환 버튼 | 전면과 후면을 바꿉니다. |

가이드 패널의 동작은 다음과 같습니다.

- 앱을 켜면 패널은 펼쳐져 있습니다.
- 가이드 버튼을 누르면 패널이 접히거나 펼쳐집니다. 애니메이션은 약 200ms입니다.
- 장면이나 가이드를 골라도 패널은 접히지 않습니다. 패널이 펼친 상태로 시작하므로, 사용자가 가이드를 여러 개 비교한다고 판단했습니다. **[추정]**
- 미리보기를 누르면 초점과 노출을 맞춥니다 (9.4). 패널은 접히지 않습니다.

4:3과 16:9의 차이는 다음과 같습니다.

- 4:3: 조작 줄은 미리보기 아래에 있습니다. 펼친 패널과 렌즈 버튼은 미리보기의 아래쪽 위에 반투명하게 겹칩니다.
- 16:9: 조작 줄, 패널, 렌즈 버튼이 모두 미리보기의 아래쪽 위에 반투명하게 겹칩니다. 패널을 접으면 가리는 영역이 줄어듭니다.

렌즈 버튼은 조작 줄에 넣지 않습니다. 렌즈 버튼은 줌과 함께 쓰는 조작이므로 iPhone 기본 카메라처럼 미리보기 위에 둡니다. "버튼을 아래에 모은다"는 결정과 조금 어긋납니다. 렌즈 버튼도 미리보기의 아래쪽에 있으므로 엄지로 닿습니다.

```dart
// lib/screens/camera_screen.dart — 아래쪽 (요약)
bool _panelOpen = true;

Column(mainAxisSize: MainAxisSize.min, children: [
  LensBar(...),                 // 9.3
  ColoredBox(
    color: Colors.black54,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: _panelOpen
            ? Column(children: [SceneTabs(...), GuidePicker(...)])
            : const SizedBox(width: double.infinity),
      ),
      ControlBar(
        ratio: _ratio,
        guide: _guide,
        panelOpen: _panelOpen,
        canFlip: _guide?.flippable ?? false,
        canSwitch: _hasFront && _hasBack,
        shutterEnabled: _controller != null && !_busy,
        onRatio: () => setState(() => _ratio = _ratio.next),
        onGuide: () => setState(() => _panelOpen = !_panelOpen),
        onShutter: _capture,
        onFlip: () => setState(() => _flipped = !_flipped),
        onSwitch: _switchCamera,
      ),
    ]),
  ),
])
```

```dart
// lib/models/photo_ratio.dart
PhotoRatio get next => this == r4x3 ? r16x9 : r4x3;
```

### 9.3 줌: 렌즈 버튼 + 핀치 줌

#### 확인한 사실

- iOS의 `camera_avfoundation` 0.10.3은 후면 렌즈를 각각 다른 카메라로 줍니다. 광각, 망원, 초광각입니다 (`CameraPlugin.swift` 131–133행).
- `CameraDescription.lensType`으로 렌즈를 구분합니다 (`wide`, `telephoto`, `ultraWide`).
- `camera` 패키지에는 `getMinZoomLevel`, `getMaxZoomLevel`, `setZoomLevel`이 있습니다. 이 값은 한 렌즈 안의 디지털 줌입니다.
- 렌즈를 바꾸려면 카메라를 다시 열어야 합니다. iPhone 기본 카메라처럼 매끄럽게 바뀌지 않습니다. 매끄러운 전환은 가상 카메라(`builtInTripleCamera`)가 필요합니다. 이 플러그인은 가상 카메라를 주지 않습니다.
- 망원 렌즈의 배율은 기종마다 다릅니다 (2×, 3×, 5×). API는 이 배율을 주지 않습니다. 초광각은 모든 iPhone에서 0.5×입니다. **[추정]**

#### 렌즈 버튼

- 후면 카메라일 때만 표시합니다. 그 기기에 있는 렌즈만 표시합니다. 렌즈가 1개이면 렌즈 버튼 줄 대신 배율만 표시합니다.
- 버튼의 글자는 ".5", "1×", "망원"입니다. 망원의 배율은 기종마다 달라서 숫자를 쓰지 않습니다.
- 지금 렌즈의 버튼은 노란색입니다. 그 버튼에 지금 배율을 표시합니다.
  - 광각에서 2배로 핀치하면: "2.0×"
  - 초광각에서 1.5배로 핀치하면: "0.8×" (0.5 × 1.5)
  - 망원에서 1.5배로 핀치하면: "망원 1.5×"
- 다른 렌즈 버튼을 누르면 그 렌즈로 카메라를 다시 엽니다. 약 0.5–1초 동안 미리보기가 멈춥니다. **[추정]** 그동안 로딩 표시를 보여 줍니다. 비율, 장면, 가이드는 그대로입니다.
- 지금 렌즈의 버튼을 누르면 그 렌즈의 1배로 돌아갑니다.

#### 핀치 줌

- 사용자가 미리보기를 두 손가락으로 벌리거나 좁힙니다. 앱이 `setZoomLevel`을 부릅니다.
- 범위는 렌즈의 최소 값부터 최대 값까지입니다. 최대 값은 **10배**로 제한합니다. 그 이상의 디지털 줌은 화질이 너무 낮습니다.
- 핀치는 렌즈를 바꾸지 않습니다. 광각에서 1배보다 작게 좁혀도 초광각으로 바뀌지 않습니다. 렌즈는 버튼으로만 바꿉니다. 핀치 중에 카메라를 다시 열면 화면이 멈춰서 불편하기 때문입니다.
- 카메라를 다시 열면(렌즈 전환, 전면·후면 전환, 백그라운드에서 복귀) 배율은 1배로 돌아갑니다.
- 가이드는 줌과 관계없이 화면에 고정됩니다.

```dart
// lib/screens/camera_screen.dart (요약)
double _zoom = 1, _minZoom = 1, _maxZoom = 1, _zoomAtStart = 1;

// _open()에서 initialize() 다음
_minZoom = await controller.getMinZoomLevel();
_maxZoom = math.min(await controller.getMaxZoomLevel(), 10);
_zoom = _minZoom;

GestureDetector(
  onScaleStart: (_) => _zoomAtStart = _zoom,
  onScaleUpdate: (d) => _setZoom(_zoomAtStart * d.scale),
  onTapUp: (d) => _focusAt(d.localPosition, size), // 9.4
  child: ...,
)

Future<void> _setZoom(double value) async {
  final zoom = value.clamp(_minZoom, _maxZoom);
  if (zoom == _zoom) return;
  setState(() => _zoom = zoom);
  await _controller?.setZoomLevel(zoom);
}
```

```dart
// lib/widgets/lens_bar.dart (새 파일)
// 렌즈 버튼 줄. 렌즈의 배율 계산은 위젯 밖의 순수 함수로 둔다. 테스트하기 위해서이다.
String zoomLabel(CameraLensType lens, double zoom) => switch (lens) {
  CameraLensType.ultraWide => '${(0.5 * zoom).toStringAsFixed(1)}×',
  CameraLensType.telephoto => '망원 ${zoom.toStringAsFixed(1)}×',
  _ => '${zoom.toStringAsFixed(1)}×',
};
```

#### 줌과 저장 사진의 영역

- iOS에서 디지털 줌은 미리보기와 사진에 함께 적용됩니다. **[추정]** 그러면 지금의 가운데 자르기가 그대로 맞습니다.
- 렌즈마다 미리보기의 비율이 다를 수 있습니다. 가운데 자르기는 비율과 관계없이 동작합니다.
- 확인 방법: 렌즈 3개와 2배 줌으로 격자를 찍습니다. 미리보기와 저장 사진의 가장자리를 비교합니다.

### 9.4 조리개 대신 노출 조절

#### 조리개를 조절할 수 없는 이유

- iPhone 카메라의 조리개는 고정입니다. iPhone 15 Pro 광각은 f/1.78입니다. 렌즈에 조리개를 바꾸는 부품이 없습니다.
- 그래서 어떤 앱도 iPhone의 조리개를 바꿀 수 없습니다. iPhone 기본 카메라의 "f값 조절"(인물 모드)은 촬영 후에 배경 흐림을 계산으로 만드는 기능입니다. 이 기능은 깊이 정보가 필요합니다. `camera` 패키지는 깊이 정보를 주지 않습니다.
- 사용자가 조리개로 원하는 것이 밝기 조절이면 노출 조절로 대신할 수 있습니다. 배경 흐림이면 MVP에서는 할 수 없습니다. **[추정]**

#### 제안: 누른 곳에 초점과 노출 맞추기 + 노출 슬라이더

iPhone 기본 카메라와 같은 방식입니다.

- 사용자가 미리보기를 한 번 누릅니다. 앱이 그 점에 초점과 노출을 맞춥니다 (`setFocusPoint`, `setExposurePoint`). 누른 곳에 노란 사각형을 잠깐 표시합니다.
- 사각형의 오른쪽에 세로 노출 슬라이더(☀)를 표시합니다. 위로 끌면 밝아지고 아래로 끌면 어두워집니다 (`setExposureOffset`).
- 범위는 −2 EV부터 +2 EV까지입니다. 기기의 범위가 더 좁으면 기기의 범위를 씁니다.
- 3초 동안 조작하지 않으면 사각형과 슬라이더가 사라집니다. 노출 값은 남습니다. 0이 아니면 조작 줄 위에 "☀ +0.7" 같은 작은 표시를 남깁니다. 이 표시를 누르면 0으로 돌아갑니다.
- 카메라를 다시 열면 노출은 0으로 돌아갑니다.

누른 점의 좌표 변환이 필요합니다. 미리보기는 가운데를 잘라서 보여 줍니다. 그래서 화면의 좌표를 카메라 영상 전체의 좌표(0–1)로 바꿉니다.

```dart
// lib/painting/filter_renderer.dart 또는 새 파일 — 순수 함수, 테스트한다
/// 잘린 미리보기 안의 점 [p](0–1)을 카메라 영상 전체의 점(0–1)으로 바꾼다.
/// [viewAspect]는 잘린 미리보기의 비율, [sourceAspect]는 영상의 비율이다.
Offset viewToSource(Offset p, double viewAspect, double sourceAspect) {
  final crop = centerCrop(Size(sourceAspect, 1), viewAspect);
  return Offset(
    (crop.left + p.dx * crop.width) / sourceAspect,
    crop.top + p.dy * crop.height,
  );
}
```

`camera` 패키지의 초점 좌표가 세로 화면 기준인지, 센서(가로) 기준인지 확인하지 못했습니다. **[미확인]** iPhone에서 화면 가장자리를 눌러서 확인합니다.

### 9.5 트레이드오프

#### 렌즈 전환 방식

| | 카메라를 다시 엶 (선택) | 가상 카메라로 매끄럽게 전환 |
|---|---|---|
| 전환할 때 | 약 0.5–1초 멈춥니다. **[추정]** | 멈추지 않습니다. 핀치로 렌즈가 자동으로 바뀝니다. |
| 구현 | `camera` 패키지로 됩니다. | 플러그인을 고치거나 Swift 코드를 씁니다. MVP 범위 밖입니다. |
| 핀치 | 렌즈 안에서만 됩니다. | 0.5×부터 끝까지 이어집니다. |

#### 노출 조절의 위치

| | 누른 곳의 슬라이더 (선택) | 조작 줄에 버튼 추가 |
|---|---|---|
| 조작 | iPhone 기본 카메라와 같습니다. 익숙합니다. | 버튼을 누르고 슬라이더를 끕니다. 2번 조작합니다. |
| 조작 줄 | 그대로 5칸입니다. | 6칸이 됩니다. 셔터가 가운데에서 벗어나거나 칸이 좁아집니다. |
| 초점 | 함께 맞춥니다. | 따로 만들어야 합니다. |

#### 가이드 패널을 펼친 상태로 시작

| 장점 | 단점 |
|---|---|
| 장면과 가이드를 바로 볼 수 있습니다. | 미리보기의 아래쪽이 처음부터 가려집니다. 16:9에서는 약 25%를 가립니다. **[추정]** |

사용자가 접으면 앱을 다시 켤 때까지 접힌 채로 있습니다. 앱을 다시 켜면 다시 펼칩니다. 접은 상태를 저장하지 않습니다 (MVP).

### 9.6 수정할 파일

| 경로 | 변경 |
|---|---|
| `lib/screens/camera_screen.dart` | 미리보기 위의 버튼을 뺍니다. 조작 줄, 가이드 패널 접기, 렌즈 전환, 핀치 줌, 누른 곳에 초점과 노출 맞추기를 추가합니다. |
| `lib/widgets/control_bar.dart` (새 파일) | 조작 줄 5칸 |
| `lib/widgets/lens_bar.dart` (새 파일) | 렌즈 버튼 줄, `zoomLabel` |
| `lib/widgets/exposure_control.dart` (새 파일) | 초점 사각형과 노출 슬라이더 |
| `lib/models/photo_ratio.dart` | `next`를 추가합니다. |
| `lib/painting/filter_renderer.dart` | `viewToSource`를 추가합니다. `centerCrop`을 함께 씁니다. |
| `test/camera_controls_test.dart` (새 파일) | 조작 줄 (버튼 5개, 반전 비활성, 콜백), 렌즈 줄 (기기에 있는 렌즈만 표시), `zoomLabel`, `PhotoRatio.next`, `viewToSource` |
| `README.md` | "화면 구성"과 "그 밖의 기능"을 바꿉니다. 조리개를 조절할 수 없다는 내용을 "알려진 제한"에 추가합니다. |

`camera_screen.dart`가 지금 약 430행입니다. 기능을 더하면 커집니다. 그래서 조작 줄, 렌즈 줄, 노출 조절을 새 파일로 분리합니다.

### 9.7 작업 순서와 확인 방법

한 번에 모두 바꾸지 않습니다. 3번에 나누어 iPhone에서 확인합니다.

| 순서 | 작업 | iPhone에서 확인할 것 |
|---|---|---|
| A | 조작 줄, 가이드 패널 | 버튼 5개가 한 줄에 있습니다. 셔터가 가운데에 있습니다. 패널이 펼친 상태로 시작합니다. 가이드 버튼으로 접고 펼칩니다. |
| B | 렌즈 버튼, 핀치 줌 | 렌즈 버튼이 이 iPhone의 렌즈 수만큼 있습니다. 렌즈가 바뀝니다. 핀치로 줌이 됩니다. 배율 표시가 맞습니다. 렌즈 3개와 2배 줌에서 미리보기와 사진의 영역이 같습니다. |
| C | 초점과 노출 | 누른 곳에 초점이 맞습니다. 가장자리를 눌러도 맞습니다. 슬라이더로 밝기가 바뀝니다. 저장한 사진의 밝기가 미리보기와 같습니다. |

각 순서가 끝날 때마다 `flutter analyze`와 `flutter test`를 실행합니다. 그 다음 iPhone에 설치합니다.

모두 끝나면 단계 6의 남은 확인 항목(3–8)을 계속합니다.

### 9.8 승인

"승인"이라고 답해 주십시오. 바꾸고 싶은 내용이 있으면 알려 주십시오. 특히 다음을 확인해 주십시오.

- 조리개: 원하신 것이 밝기 조절입니까, 배경 흐림입니까? 밝기 조절이면 9.4대로 진행합니다.
- 패널: 장면이나 가이드를 골라도 접히지 않게 했습니다. 괜찮습니까?
