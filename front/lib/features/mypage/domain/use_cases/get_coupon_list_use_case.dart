import 'package:front/features/mypage/domain/entities/coupon_entity.dart';
import 'package:front/features/mypage/domain/repositories/coupon_repository.dart';

/// 쿠폰 목록 조회 UseCase
class GetCouponListUseCase {
  final CouponRepository _repository;

  const GetCouponListUseCase(this._repository);

  /// UseCase 실행
  Future<List<CouponEntity>> execute() async {
    return await _repository.getCouponList();
  }
}
