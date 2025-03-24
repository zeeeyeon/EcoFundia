/// 앱 전체에서 사용되는 환경 설정을 관리하는 클래스
class AppConfig {
  /// API 서버 기본 URL
  static const String baseUrl = 'https://j12e206.p.ssafy.io/api';

  /// API 엔드포인트 모음
  static const apiEndpoints = ApiEndpoints();

  /// 토큰 관련 설정
  static const tokenConfig = TokenConfig();

  // 다른 환경 설정 값들은 여기에 추가
}

/// API 엔드포인트를 관리하는 클래스
class ApiEndpoints {
  // Auth 관련 엔드포인트
  final String login = '/user/login';
  final String signup = '/user/signup';
  final String refresh = '/user/reissue';

  // 다른 기능별 엔드포인트는 여기에 추가
  const ApiEndpoints();
}

/// 토큰 관련 설정을 관리하는 클래스
class TokenConfig {
  /// 토큰 자동 갱신 시간 (분)
  /// 앱 실행 시 토큰이 이 시간 내에 만료되면 자동으로 갱신
  final int refreshBeforeExpirationMinutes = 5;

  /// 토큰 만료 전 체크 간격 (분)
  final int checkExpirationIntervalMinutes = 5;

  const TokenConfig();
}
