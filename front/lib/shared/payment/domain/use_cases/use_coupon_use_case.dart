import 'package:front/features/mypage/domain/repositories/coupon_repository.dart';

/// 쿠폰 사용 UseCase
/// 결제가 완료된 후 쿠폰을 사용 처리하는 비즈니스 로직을 담당합니다.
class UseCouponUseCase {
  final CouponRepository _repository;

  const UseCouponUseCase(this._repository);

  /// 쿠폰 사용
  /// [couponId] 사용할 쿠폰의 ID
  Future<bool> execute(int couponId) async {
    return await _repository.useCoupon(couponId);
  }
}
