/// 로딩 상태를 나타내는 enum
enum LoadingState {
  /// 초기 상태 (로딩 전)
  initial,

  /// 로딩 중
  loading,

  /// 로딩 완료
  loaded,

  /// 에러 발생
  error,
}
