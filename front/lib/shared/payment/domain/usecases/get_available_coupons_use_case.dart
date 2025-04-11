import 'package:front/features/mypage/domain/entities/coupon_entity.dart';
import 'package:front/features/mypage/domain/repositories/coupon_repository.dart';

/// 사용 가능한 쿠폰 목록 조회 UseCase
/// 결제 화면에서 사용 가능한 쿠폰 목록을 가져오는 비즈니스 로직을 담당합니다.
class GetAvailableCouponsUseCase {
  final CouponRepository _repository;

  const GetAvailableCouponsUseCase(this._repository);

  /// UseCase 실행
  Future<List<CouponEntity>> execute() async {
    return await _repository.getAvailableCoupons();
  }
}
