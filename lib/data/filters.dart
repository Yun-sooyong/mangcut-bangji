import '../models/photo_filter.dart';

// 필터의 값은 실제 기기에서 보면서 조정한다.
// 이름에 등록 상표를 쓰지 않는다.
// 기본 필터는 색만 바꾼다. 빈티지 필터는 입자와 비네팅을 더한다.

const original = PhotoFilter(
  id: 'original',
  name: '원본',
  category: FilterCategory.basic,
);

final filters = <PhotoFilter>[
  original,
  PhotoFilter(
    id: 'vivid',
    name: '선명하게',
    category: FilterCategory.basic,
    matrix: ColorMatrix.saturation(1.2).then(ColorMatrix.contrast(1.1)),
  ),
  PhotoFilter(
    id: 'warm',
    name: '따뜻하게',
    category: FilterCategory.basic,
    matrix: ColorMatrix.gains(1.06, 1.0, 0.92),
  ),
  PhotoFilter(
    id: 'cool',
    name: '차갑게',
    category: FilterCategory.basic,
    matrix: ColorMatrix.gains(0.94, 1.0, 1.06),
  ),
  PhotoFilter(
    id: 'mono',
    name: '흑백',
    category: FilterCategory.basic,
    matrix: ColorMatrix.saturation(0).then(ColorMatrix.contrast(1.05)),
  ),
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
  PhotoFilter(
    id: 'faded',
    name: '바랜 사진',
    category: FilterCategory.vintage,
    matrix: ColorMatrix.saturation(0.6)
        .then(ColorMatrix.gains(1.03, 1.0, 0.94))
        .then(ColorMatrix.contrast(0.82))
        .then(ColorMatrix.fade(0.1)),
    grain: 0.22,
    vignette: 0.25,
  ),
  PhotoFilter(
    id: 'sunset',
    name: '노을빛',
    category: FilterCategory.vintage,
    matrix: ColorMatrix.saturation(1.05)
        .then(ColorMatrix.gains(1.14, 1.0, 0.8))
        .then(ColorMatrix.brightness(0.03)),
    grain: 0.12,
    vignette: 0.18,
  ),
  PhotoFilter(
    id: 'cool_film',
    name: '차가운 필름',
    category: FilterCategory.vintage,
    matrix: ColorMatrix.saturation(0.85)
        .then(ColorMatrix.gains(0.92, 1.02, 1.08))
        .then(ColorMatrix.contrast(0.92))
        .then(ColorMatrix.fade(0.05)),
    grain: 0.15,
    vignette: 0.15,
  ),
  PhotoFilter(
    id: 'vivid_slide',
    name: '진한 슬라이드',
    category: FilterCategory.vintage,
    matrix: ColorMatrix.saturation(1.35).then(ColorMatrix.contrast(1.15)),
    grain: 0.08,
    vignette: 0.22,
  ),
  PhotoFilter(
    id: 'instant',
    name: '즉석 사진',
    category: FilterCategory.vintage,
    matrix: ColorMatrix.saturation(0.9)
        .then(ColorMatrix.gains(1.0, 1.04, 0.95))
        .then(ColorMatrix.contrast(0.85))
        .then(ColorMatrix.fade(0.08))
        .then(ColorMatrix.brightness(0.05)),
    grain: 0.1,
    vignette: 0.3,
  ),
  PhotoFilter(
    id: 'mono_film',
    name: '흑백 필름',
    category: FilterCategory.vintage,
    matrix: ColorMatrix.saturation(0).then(ColorMatrix.contrast(1.15)),
    grain: 0.3,
    vignette: 0.25,
  ),
];
