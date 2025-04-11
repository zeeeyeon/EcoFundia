import 'package:front/features/mypage/domain/repositories/coupon_repository.dart';

/// 쿠폰 개수 조회 UseCase
class GetCouponCountUseCase {
  final CouponRepository _repository;

  const GetCouponCountUseCase(this._repository);

  /// UseCase 실행
  Future<int> execute() async {
    return await _repository.getCouponCount();
  }
}
