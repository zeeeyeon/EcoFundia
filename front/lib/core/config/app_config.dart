/// 앱 전체에서 사용되는 환경 설정을 관리하는 클래스
class AppConfig {
  /// API 서버 기본 URL
  static const String baseUrl = 'http://192.168.30.193:8081';

  /// API 엔드포인트 모음
  static const apiEndpoints = ApiEndpoints();

  // 다른 환경 설정 값들은 여기에 추가
}

/// API 엔드포인트를 관리하는 클래스
class ApiEndpoints {
  // Auth 관련 엔드포인트
  final String login = '/user/login';
  final String signup = '/user/signup';
  final String refresh = '/user/reissue';
  final String logout = '/auth/logout';

  // 다른 기능별 엔드포인트는 여기에 추가
  const ApiEndpoints();
}
