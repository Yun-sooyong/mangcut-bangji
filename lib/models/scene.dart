import 'guide.dart';

/// 촬영 장면 1개. 그 장면에 어울리는 가이드를 묶는다.
class Scene {
  const Scene({required this.id, required this.name, required this.guides});

  final String id;
  final String name;
  final List<Guide> guides;
}
