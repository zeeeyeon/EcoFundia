import 'package:front/features/mypage/domain/entities/coupon_entity.dart';
import 'package:front/features/mypage/domain/entities/coupon_apply_result.dart';

/// 쿠폰 저장소 인터페이스
abstract class CouponRepository {
  /// 사용자의 쿠폰 개수 조회
  Future<int> getCouponCount();

  /// 사용자의 쿠폰 목록 조회
  Future<List<CouponEntity>> getCouponList();

  /// 쿠폰 발급 신청
  /// 반환 타입: [CouponApplyResult]
  /// - [CouponApplySuccess] - 쿠폰 발급 성공
  /// - [AlreadyIssuedFailure] - 이미 발급된 쿠폰
  /// - [NetworkFailure] - 네트워크 오류
  /// - [UnknownFailure] - 알 수 없는 오류
  Future<CouponApplyResult> applyCoupon();

  /// 사용 가능한 쿠폰 목록 조회 (결제 시)
  Future<List<CouponEntity>> getAvailableCoupons();
}
