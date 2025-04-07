/// API 관련 상수
class ApiConstants {
  /// API 기본 URL
  static const String baseUrl =
      'https://api.example.com'; // TODO: 실제 API URL로 변경

  /// API 버전
  static const String apiVersion = 'v1';

  /// API 타임아웃 (초)
  static const int timeout = 30;

  /// API 재시도 횟수
  static const int maxRetries = 3;

  /// API 재시도 간격 (초)
  static const int retryInterval = 1;
}

/// 쿠폰 관련 API 엔드포인트
class CouponEndpoints {
  /// 쿠폰 개수 조회
  static const String count = '/api/coupons/count';

  /// 쿠폰 발급
  static const String apply = '/api/coupons/apply';

  /// 쿠폰 목록 조회
  static const String list = '/api/coupons/list';

  /// 쿠폰 상세 조회
  static const String detail = '/api/coupons/detail';

  /// 쿠폰 사용
  static const String use = '/api/coupons/use';
}

/// 인증 관련 API 엔드포인트
class AuthEndpoints {
  /// 로그인
  static const String login = '/api/auth/login';

  /// 로그아웃
  static const String logout = '/api/auth/logout';

  /// 회원가입
  static const String register = '/api/auth/register';

  /// 토큰 갱신
  static const String refresh = '/api/auth/refresh';
}

/// 사용자 관련 API 엔드포인트
class UserEndpoints {
  /// 사용자 정보 조회
  static const String profile = '/api/users/profile';

  /// 사용자 정보 수정
  static const String update = '/api/users/update';

  /// 사용자 삭제
  static const String delete = '/api/users/delete';
}
