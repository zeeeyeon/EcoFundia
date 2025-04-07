import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/data/repositories/coupon_repository_impl.dart';
import 'package:front/features/mypage/domain/entities/coupon_entity.dart';
import 'package:front/shared/payment/domain/usecases/get_available_coupons_use_case.dart';
import 'package:front/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';

/// 결제에서 사용 가능한 쿠폰 UseCase Provider
final getAvailableCouponsUseCaseProvider =
    Provider<GetAvailableCouponsUseCase>((ref) {
  final repository = ref.watch(couponRepositoryProvider);
  return GetAvailableCouponsUseCase(repository);
});

/// 사용 가능한 쿠폰 목록을 위한 FutureProvider
/// autoDispose 속성을 사용하여 Provider가 더 이상 사용되지 않을 때 상태를 정리합니다.
/// 이를 통해 다이얼로그가 열릴 때마다 새로운 쿠폰 목록을 가져올 수 있습니다.
final availableCouponsProvider =
    FutureProvider.autoDispose<List<CouponEntity>>((ref) async {
  final useCase = ref.watch(getAvailableCouponsUseCaseProvider);
  LoggerUtil.d('사용 가능한 쿠폰 목록 조회 시작');

  try {
    final coupons = await useCase.execute();
    LoggerUtil.d('사용 가능한 쿠폰 목록 조회 성공: ${coupons.length}개');
    return coupons;
  } catch (e) {
    LoggerUtil.e('사용 가능한 쿠폰 목록 조회 실패', e);
    return [];
  }
});

/// 쿠폰 색상 관련 유틸리티 함수를 제공하는 Provider
/// 이를 통해 쿠폰 관련 UI 색상 로직을 중앙화합니다.
final couponColorUtilProvider = Provider<CouponColorUtil>((ref) {
  return CouponColorUtil();
});

/// 쿠폰 관련 UI 색상 로직을 담당하는 유틸리티 클래스
class CouponColorUtil {
  /// 선택된 쿠폰의 배경색을 반환합니다.
  Color getCouponBackgroundColor(Color baseColor, bool isSelected,
      {double opacity = 0.1}) {
    if (!isSelected) return Colors.white;

    // 미리 정의된 색상 사용
    if (baseColor == AppColors.primary) {
      // 10% 투명도의 프라이머리 색상
      return const Color(0x1AA3D80D); // AppColors.primary with 10% opacity
    }

    // 다른 색상들에 대한 처리 (필요시 추가)
    return Colors.white;
  }

  /// 쿠폰 텍스트 색상을 반환합니다.
  Color getCouponTextColor(
      Color primaryColor, Color darkGreyColor, bool isSelected) {
    return isSelected ? primaryColor : darkGreyColor;
  }

  /// 쿠폰 아이콘 색상을 반환합니다.
  Color getCouponIconColor(
      Color primaryColor, Color greyColor, bool isSelected) {
    return isSelected ? primaryColor : greyColor;
  }
}
