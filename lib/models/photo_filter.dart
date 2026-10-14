/// 4×5 색 행렬. [ColorFilter.matrix]와 같은 형식이다.
///
/// 각 행은 `[R, G, B, A, offset]`이다. offset의 범위는 0–255이다.
class ColorMatrix {
  const ColorMatrix(this.values);

  final List<double> values;

  static const identity = ColorMatrix([
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0, //
    0, 0, 1, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  /// 채도. 0은 흑백, 1은 원본이다.
  factory ColorMatrix.saturation(double s) {
    const lr = 0.2126, lg = 0.7152, lb = 0.0722;
    final i = 1 - s;
    return ColorMatrix([
      lr * i + s, lg * i, lb * i, 0, 0, //
      lr * i, lg * i + s, lb * i, 0, 0, //
      lr * i, lg * i, lb * i + s, 0, 0, //
      0, 0, 0, 1, 0, //
    ]);
  }

  /// 대비. 1은 원본이다. 중간 회색을 기준으로 늘린다.
  factory ColorMatrix.contrast(double c) {
    final o = 127.5 * (1 - c);
    return ColorMatrix([
      c, 0, 0, 0, o, //
      0, c, 0, 0, o, //
      0, 0, c, 0, o, //
      0, 0, 0, 1, 0, //
    ]);
  }

  /// 밝기. 0은 원본이다. 범위는 -1–1이다.
  factory ColorMatrix.brightness(double b) {
    final o = 255 * b;
    return ColorMatrix([
      1, 0, 0, 0, o, //
      0, 1, 0, 0, o, //
      0, 0, 1, 0, o, //
      0, 0, 0, 1, 0, //
    ]);
  }

  /// 채널별 배율. 색온도와 색조를 만든다.
  factory ColorMatrix.gains(double r, double g, double b) {
    return ColorMatrix([
      r, 0, 0, 0, 0, //
      0, g, 0, 0, 0, //
      0, 0, b, 0, 0, //
      0, 0, 0, 1, 0, //
    ]);
  }

  /// 검정을 들어 올린다. 흰색은 그대로 둔다. 바랜 느낌을 만든다.
  factory ColorMatrix.fade(double amount) {
    final s = 1 - amount;
    final o = 255 * amount;
    return ColorMatrix([
      s, 0, 0, 0, o, //
      0, s, 0, 0, o, //
      0, 0, s, 0, o, //
      0, 0, 0, 1, 0, //
    ]);
  }

  /// 이 행렬을 먼저 적용하고 [next]를 나중에 적용하는 행렬을 만든다.
  ColorMatrix then(ColorMatrix next) {
    final a = next.values;
    final b = values;
    final out = List<double>.filled(20, 0);
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 5; col++) {
        var sum = 0.0;
        for (var k = 0; k < 4; k++) {
          sum += a[row * 5 + k] * b[k * 5 + col];
        }
        if (col == 4) sum += a[row * 5 + 4];
        out[row * 5 + col] = sum;
      }
    }
    return ColorMatrix(out);
  }

  /// 색 1개에 행렬을 적용한다. 입력과 출력의 범위는 0–255이다.
  (double r, double g, double b) transform(double r, double g, double b) {
    double row(int i) {
      final v =
          values[i] * r +
          values[i + 1] * g +
          values[i + 2] * b +
          values[i + 3] * 255 +
          values[i + 4];
      return v.clamp(0, 255).toDouble();
    }

    return (row(0), row(5), row(10));
  }
}

/// 필터의 묶음. 결과 화면이 묶음별로 필터를 나눠서 보여 준다.
enum FilterCategory {
  basic('기본'),
  vintage('빈티지');

  const FilterCategory(this.label);

  final String label;
}

/// 필터 1개. 화면 표시와 저장이 이 값을 함께 쓴다.
class PhotoFilter {
  const PhotoFilter({
    required this.id,
    required this.name,
    required this.category,
    this.matrix = ColorMatrix.identity,
    this.grain = 0,
    this.vignette = 0,
  });

  final String id;
  final String name;
  final FilterCategory category;
  final ColorMatrix matrix;

  /// 입자의 강도. 범위는 0–1이다.
  final double grain;

  /// 가장자리를 어둡게 하는 강도. 범위는 0–1이다.
  final double vignette;
}
