import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/data/services/coupon_service.dart';
import 'package:front/features/mypage/domain/entities/coupon_entity.dart';
import 'package:front/features/mypage/domain/entities/coupon_apply_result.dart';
import 'package:front/features/mypage/domain/repositories/coupon_repository.dart';
import 'package:front/utils/logger_util.dart';

/// 쿠폰 저장소 구현체
class CouponRepositoryImpl implements CouponRepository {
  final CouponService _couponService;

  CouponRepositoryImpl(this._couponService);

  @override
  Future<int> getCouponCount() async {
    try {
      return await _couponService.getCouponCount();
    } catch (e) {
      LoggerUtil.e('쿠폰 개수 조회 저장소 오류', e);
      rethrow;
    }
  }

  @override
  Future<List<CouponEntity>> getCouponList() async {
    try {
      final couponModels = await _couponService.getCouponList();
      // 모델을 엔티티로 변환
      return couponModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      LoggerUtil.e('쿠폰 목록 조회 저장소 오류', e);
      rethrow;
    }
  }

  @override
  Future<CouponApplyResult> applyCoupon() async {
    try {
      LoggerUtil.d('🎫 CouponRepositoryImpl: applyCoupon 시작');
      LoggerUtil.i('🎫 [리포지토리] 쿠폰 발급 API 서비스 호출 준비');

      // 쿠폰 서비스의 applyCoupon 메서드 호출
      LoggerUtil.i('🎫 [리포지토리] CouponService.applyCoupon() 호출 직전');
      final result = await _couponService.applyCoupon();
      LoggerUtil.i('🎫 [리포지토리] CouponService로부터 결과 수신: $result');

      // 결과 처리 (CouponApplyResult 반환)
      // 서비스에서 이미 CouponApplyResult를 반환한다고 가정
      LoggerUtil.d('🎫 CouponRepositoryImpl: applyCoupon 결과 반환');
      return result;
    } catch (e) {
      // 이 부분은 서비스에서 Exception을 throw하는 경우를 처리하는 코드입니다.
      // 서비스가 CouponApplyResult를 반환하도록 수정한 후에는 사용되지 않을 수 있습니다.
      LoggerUtil.e('🎫 CouponRepositoryImpl: 쿠폰 발급 신청 저장소 오류', e);

      if (e.toString().contains('이미 발급받은 쿠폰입니다')) {
        return const AlreadyIssuedFailure();
      }

      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<List<CouponEntity>> getAvailableCoupons() async {
    try {
      final couponModels = await _couponService.getAvailableCoupons();
      // 모델을 엔티티로 변환
      return couponModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      LoggerUtil.e('사용 가능 쿠폰 목록 조회 저장소 오류', e);
      rethrow;
    }
  }

  @override
  Future<bool> useCoupon(int couponId) async {
    try {
      return await _couponService.useCoupon(couponId);
    } catch (e) {
      LoggerUtil.e('쿠폰 사용 저장소 오류', e);
      rethrow;
    }
  }
}

/// 쿠폰 Repository Provider
final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  final couponService = ref.watch(couponServiceProvider);
  return CouponRepositoryImpl(couponService);
});
