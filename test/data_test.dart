import 'package:flutter_test/flutter_test.dart';
import 'package:mangcut_bangji/data/filters.dart';
import 'package:mangcut_bangji/data/guides.dart';
import 'package:mangcut_bangji/data/scenes.dart';
import 'package:mangcut_bangji/models/photo_filter.dart';
import 'package:mangcut_bangji/models/photo_ratio.dart';

void main() {
  test('가이드는 14종이고 id가 겹치지 않는다', () {
    expect(allGuides, hasLength(14));
    expect(allGuides.map((g) => g.id).toSet(), hasLength(14));
  });

  test('모든 가이드의 좌표는 두 비율에서 0–1 범위이다', () {
    for (final ratio in PhotoRatio.values) {
      for (final guide in allGuides) {
        final shapes = guide.build(ratio.aspect);
        final reason = '${guide.id} ${ratio.label}';
        expect(shapes, isNotEmpty, reason: reason);
        for (final shape in shapes) {
          for (final p in shape.points) {
            expect(p.dx, inInclusiveRange(0, 1), reason: reason);
            expect(p.dy, inInclusiveRange(0, 1), reason: reason);
          }
        }
      }
    }
  });

  test('장면은 5개이고 모든 가이드가 목록에 있다', () {
    expect(scenes, hasLength(5));
    for (final scene in scenes) {
      expect(scene.guides, isNotEmpty, reason: scene.id);
      for (final guide in scene.guides) {
        expect(allGuides, contains(guide), reason: scene.id);
      }
    }
  });

  test('모든 가이드는 장면 1개 이상에 들어 있다', () {
    final used = {for (final s in scenes) ...s.guides};
    expect(used, containsAll(allGuides));
  });

  test('필터는 기본 5개와 빈티지 7개이다', () {
    expect(filters.first, original);
    expect(filters.map((f) => f.id).toSet(), hasLength(12));
    expect(
      filters.where((f) => f.category == FilterCategory.basic),
      hasLength(5),
    );
    expect(
      filters.where((f) => f.category == FilterCategory.vintage),
      hasLength(7),
    );
    for (final f in filters) {
      expect(f.matrix.values, hasLength(20), reason: f.id);
      expect(f.grain, inInclusiveRange(0, 1), reason: f.id);
      expect(f.vignette, inInclusiveRange(0, 1), reason: f.id);
    }
  });

  test('기본 필터에는 입자와 비네팅이 없다', () {
    for (final f in filters.where((f) => f.category == FilterCategory.basic)) {
      expect(f.grain, 0, reason: f.id);
      expect(f.vignette, 0, reason: f.id);
    }
  });
}
