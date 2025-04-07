import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/data/repositories/coupon_repository_impl.dart';
import 'package:front/features/mypage/domain/entities/coupon_entity.dart';
import 'package:front/shared/payment/domain/use_cases/get_available_coupons_use_case.dart';

/// 결제에서 사용 가능한 쿠폰 UseCase Provider
final getAvailableCouponsUseCaseProvider =
    Provider<GetAvailableCouponsUseCase>((ref) {
  final repository = ref.watch(couponRepositoryProvider);
  return GetAvailableCouponsUseCase(repository);
});

/// 사용 가능한 쿠폰 목록을 위한 FutureProvider
final availableCouponsProvider =
    FutureProvider<List<CouponEntity>>((ref) async {
  final useCase = ref.watch(getAvailableCouponsUseCaseProvider);
  return await useCase.execute();
});
