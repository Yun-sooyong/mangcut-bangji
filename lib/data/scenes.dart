import '../models/scene.dart';
import 'guides.dart';

final scenes = <Scene>[
  Scene(
    id: 'portrait',
    name: '인물',
    guides: [thirds, goldenSpiral, center, negativeSpace],
  ),
  Scene(
    id: 'landscape',
    name: '풍경',
    guides: [thirds, goldenSection, diagonal, sCurve, negativeSpace],
  ),
  Scene(
    id: 'architecture',
    name: '건축·도시',
    guides: [symmetry, frame, triangle, repetition],
  ),
  Scene(
    id: 'food',
    name: '음식·카페',
    guides: [center, thirds, diagonal, triangle],
  ),
  Scene(
    id: 'street',
    name: '길·골목',
    guides: [vanishingPoint, leadingLines, symmetry, vShape],
  ),
];
