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
      // 서비스 호출 및 결과 직접 반환
      final result = await _couponService.applyCoupon();
      LoggerUtil.i('🎫 [리포지토리] CouponService로부터 결과 수신: $result');
      return result;
    } catch (e) {
      // 서비스 레벨에서 처리되지 않은 예외 발생 시 (가능성은 낮음)
      LoggerUtil.e('🎫 CouponRepositoryImpl: 예상치 못한 저장소 오류', e);
      return UnknownFailure('쿠폰 발급 중 알 수 없는 오류가 발생했습니다: ${e.toString()}');
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
}

/// 쿠폰 Repository Provider
final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  final couponService = ref.watch(couponServiceProvider);
  return CouponRepositoryImpl(couponService);
});
