/// 앱 전체에서 사용되는 환경 설정을 관리하는 클래스
class AppConfig {
  /// API 서버 기본 URL
  static const String baseUrl = 'https://j12e206.p.ssafy.io/api';

  /// API 엔드포인트 모음
  static const apiEndpoints = ApiEndpoints();

  /// 토큰 관련 설정
  static const tokenConfig = TokenConfig();

  /// 인증 관련 설정
  static const authConfig = AuthConfig();

  // 다른 환경 설정 값들은 여기에 추가
}

/// API 엔드포인트를 관리하는 클래스
class ApiEndpoints {
  // Auth 관련 엔드포인트
  final String login = '/user/login'; // Google 로그인 전용
  final String signup = '/user/signup';
  final String reissue = '/user/reissue';
  final String logout = '/user/logout'; // 로그아웃 엔드포인트 추가
  final String funding = '/funding';
  final String wishlist = '/wishlist';
  final String mypage = '/mypage';
  final String test = '/user/health';

  // 쿠폰 관련 엔드포인트
  final String couponCount = '/user/coupons/count'; // 쿠폰 개수 조회
  final String couponApply = '/user/coupons/apply'; // 쿠폰 발급 신청
  final String couponList = '/user/coupons/list'; // 쿠폰 목록 조회
  final String couponUse = '/user/order/coupon'; // 결제 완료 시 쿠폰 사용 처리

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

/// 인증 관련 설정을 관리하는 클래스
class AuthConfig {
  /// 웹 환경에서 사용하는 Google 클라이언트 ID
  final String webClientId =
      '609004819005-m2h2elam67hkc5f6r7oajvhpc5555du8.apps.googleusercontent.com';

  /// 모바일 환경에서 서버 인증에 사용하는 Google 클라이언트 ID
  final String serverClientId =
      '609004819005-h718agaqj9pgv1t7ja6sr8rq3n0ffeqv.apps.googleusercontent.com';

  const AuthConfig();
}
