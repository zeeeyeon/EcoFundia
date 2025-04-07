import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/shared/payment/domain/providers/payment_providers.dart';
import 'package:front/shared/payment/ui/view_model/payment_view_model.dart';
import 'package:front/utils/logger_util.dart';
import 'package:intl/intl.dart';

/// 쿠폰 선택 다이얼로그
class CouponDialog extends ConsumerWidget {
  /// 쿠폰 선택 콜백 - 쿠폰 ID를 반환하도록 수정
  final Function(int couponId, int discountAmount) onCouponSelected;

  const CouponDialog({
    Key? key,
    required this.onCouponSelected,
  }) : super(key: key);

  /// 쿠폰 선택 다이얼로그를 표시합니다.
  static Future<void> show({
    required BuildContext context,
    required Function(int couponId, int discountAmount) onCouponSelected,
    required WidgetRef ref,
  }) async {
    // 다이얼로그를 표시하기 전에 쿠폰 목록을 새로고침합니다.
    final couponsAsync = ref.refresh(availableCouponsProvider);

    // AsyncValue에서 데이터 추출
    final int couponCount =
        couponsAsync.hasValue ? couponsAsync.value!.length : 0;
    LoggerUtil.d('쿠폰 다이얼로그 표시 전 쿠폰 목록 새로고침 완료: $couponCount개 쿠폰 로드됨');

    if (context.mounted) {
      return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) => CouponDialog(
          onCouponSelected: onCouponSelected,
        ),
      );
    }
    return;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 사용 가능한 쿠폰 목록을 가져옵니다.
    final availableCouponsAsync = ref.watch(availableCouponsProvider);

    // 현재 선택된 쿠폰 ID를 가져옵니다.
    final paymentState = ref.watch(paymentViewModelProvider);
    final locallySelectedCouponId = paymentState.locallySelectedCouponId;

    // 색상 유틸리티
    final colorUtil = ref.watch(couponColorUtilProvider);

    LoggerUtil.d('쿠폰 다이얼로그 빌드: 로컬 선택 쿠폰 ID = $locallySelectedCouponId');

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDialogHeader(context),
          const Divider(height: 1, color: AppColors.lightGrey),
          _buildCouponList(availableCouponsAsync, locallySelectedCouponId, ref,
              context, colorUtil),
        ],
      ),
    );
  }

  /// 다이얼로그 헤더 위젯
  Widget _buildDialogHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '사용 가능한 쿠폰',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            color: AppColors.grey,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// 쿠폰 목록 위젯
  Widget _buildCouponList(
    AsyncValue<List<dynamic>> availableCouponsAsync,
    int? locallySelectedCouponId,
    WidgetRef ref,
    BuildContext context,
    CouponColorUtil colorUtil,
  ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 400,
        minHeight: 200,
      ),
      child: availableCouponsAsync.when(
        data: (coupons) {
          if (coupons.isEmpty) {
            return _buildEmptyCouponsMessage();
          }

          return ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: coupons.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: AppColors.lightGrey,
            ),
            itemBuilder: (context, index) {
              final coupon = coupons[index];

              // 현재 쿠폰이 로컬에서 선택된 상태인지 확인
              final bool isSelectedLocally =
                  locallySelectedCouponId == coupon.couponId;

              return _buildCouponItem(
                coupon: coupon,
                isSelected: isSelectedLocally,
                ref: ref,
                context: context,
                colorUtil: colorUtil,
              );
            },
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              '쿠폰 목록을 불러오는 중 오류가 발생했습니다.\n${error.toString()}',
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  /// 쿠폰이 없을 때 표시하는 메시지 위젯
  Widget _buildEmptyCouponsMessage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          '사용 가능한 쿠폰이 없습니다.',
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// 개별 쿠폰 아이템 위젯
  Widget _buildCouponItem({
    required dynamic coupon,
    required bool isSelected,
    required WidgetRef ref,
    required BuildContext context,
    required CouponColorUtil colorUtil,
  }) {
    return InkWell(
      onTap: isSelected
          ? () {
              // 이미 선택된 쿠폰을 다시 탭하면 선택 해제
              final viewModel = ref.read(paymentViewModelProvider.notifier);
              viewModel.removeCoupon();
              Navigator.pop(context);
            }
          : () {
              onCouponSelected(coupon.couponId, coupon.discountAmount);
              Navigator.pop(context);
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        // 선택된 쿠폰은 배경색 변경
        color:
            colorUtil.getCouponBackgroundColor(AppColors.primary, isSelected),
        child: Row(
          children: [
            // 선택 상태 아이콘
            isSelected
                ? const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 24,
                  )
                : const Icon(
                    Icons.radio_button_unchecked,
                    color: AppColors.grey,
                    size: 24,
                  ),
            const SizedBox(width: 12),
            // 쿠폰 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.name,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                      // 선택된 쿠폰은 텍스트 색상 변경
                      color: colorUtil.getCouponTextColor(
                          AppColors.primary, AppColors.darkGrey, isSelected),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${NumberFormat('#,##0').format(coupon.discountAmount)}원',
                    style: AppTextStyles.body1.copyWith(
                      color: colorUtil.getCouponTextColor(
                          AppColors.primary,
                          AppColors.primary.withAlpha((0.8 * 255).toInt()),
                          isSelected),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${coupon.expirationDate}까지 사용 가능',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
