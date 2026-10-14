/// 사용자가 고르는 사진의 비율. 화면은 세로로 고정한다.
enum PhotoRatio {
  r4x3('4:3', 3 / 4),
  r16x9('16:9', 9 / 16);

  const PhotoRatio(this.label, this.aspect);

  final String label;

  /// 세로 화면에서 너비 ÷ 높이.
  final double aspect;

  /// 비율 버튼을 누르면 바뀌는 다음 비율.
  PhotoRatio get next => this == r4x3 ? r16x9 : r4x3;
}
