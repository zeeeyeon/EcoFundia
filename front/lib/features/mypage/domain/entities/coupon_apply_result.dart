import 'package:flutter/foundation.dart';

/// 쿠폰 발급 결과를 나타내는 타입 (sealed class 패턴)
@immutable
sealed class CouponApplyResult {
  const CouponApplyResult();
}

/// 쿠폰 발급 성공 결과
class CouponApplySuccess extends CouponApplyResult {
  const CouponApplySuccess();
}

/// 쿠폰 발급 실패 기본 클래스
abstract class CouponApplyFailure extends CouponApplyResult {
  final String message;
  const CouponApplyFailure(this.message);
}

/// 이미 발급된 쿠폰 실패 케이스
class AlreadyIssuedFailure extends CouponApplyFailure {
  const AlreadyIssuedFailure() : super('이미 발급받은 쿠폰입니다.');
}

/// 권한 없음 에러 (403 응답)
class AuthorizationFailure extends CouponApplyFailure {
  const AuthorizationFailure() : super('쿠폰을 받을 권한이 없습니다. 로그인이 필요합니다.');
}

/// 네트워크 오류 실패 케이스
class NetworkFailure extends CouponApplyFailure {
  const NetworkFailure(String message) : super(message);
}

/// 알 수 없는 오류 실패 케이스
class UnknownFailure extends CouponApplyFailure {
  const UnknownFailure(String message) : super(message);
}
