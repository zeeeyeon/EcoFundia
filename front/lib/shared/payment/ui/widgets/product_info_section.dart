import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/shared/payment/ui/view_model/payment_view_model.dart';
import 'package:front/shared/payment/ui/widgets/coupon_dialog.dart';
import 'package:front/shared/payment/domain/providers/payment_providers.dart';
import 'package:intl/intl.dart';
import 'package:front/utils/logger_util.dart';

/// 상품 정보 섹션 위젯
class ProductInfoSection extends ConsumerWidget {
  const ProductInfoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(paymentViewModelProvider);
    final paymentVM = ref.read(paymentViewModelProvider.notifier);
    final colorUtil = ref.watch(couponColorUtilProvider);

    // 로딩 중 표시
    if (paymentState.payment == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final payment = paymentState.payment!;
    final numberFormat = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColorLight,
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제품 정보
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제품 이미지
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CachedNetworkImage(
                    imageUrl: payment.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: AppColors.extraLightGrey,
                      highlightColor: AppColors.lightGrey,
                      child: Container(
                        color: AppColors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.extraLightGrey,
                      child: const Icon(Icons.error, color: AppColors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              // 제품 텍스트 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.sellerName,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      payment.productName,
                      style: AppTextStyles.body1.copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '${numberFormat.format(payment.price)}원',
                      style: AppTextStyles.body1.copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          const Divider(color: AppColors.lightGrey),
          const SizedBox(height: 16.0),

          // 수량 조절 및 쿠폰 적용 부분
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 수량 조절
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '수량',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        // 감소 버튼
                        _buildQuantityButton(
                          icon: Icons.remove,
                          onTap: () => paymentVM.decrementQuantity(),
                          isEnabled: payment.quantity > 1,
                        ),
                        Container(
                          width: 40.0,
                          height: 32.0,
                          alignment: Alignment.center,
                          child: Text(
                            '${payment.quantity}',
                            style: AppTextStyles.body1.copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // 증가 버튼
                        _buildQuantityButton(
                          icon: Icons.add,
                          onTap: () => paymentVM.incrementQuantity(),
                          isEnabled: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 쿠폰 적용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '쿠폰',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    InkWell(
                      onTap: () async {
                        // 쿠폰 목록 새로고침 후 다이얼로그 표시
                        LoggerUtil.d('쿠폰 목록 새로고침 요청');
                        final coupons =
                            await ref.refresh(availableCouponsProvider.future);
                        LoggerUtil.d(
                            '쿠폰 목록 새로고침 완료: ${coupons.length}개 쿠폰 로드됨');

                        if (context.mounted) {
                          // 쿠폰 선택 다이얼로그 표시
                          CouponDialog.show(
                            context: context,
                            onCouponSelected: (couponId, discountAmount) {
                              paymentVM.applyCouponWithId(
                                  couponId, discountAmount);
                            },
                            ref: ref,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.lightGrey),
                          borderRadius: BorderRadius.circular(4.0),
                          color: colorUtil.getCouponBackgroundColor(
                              AppColors.primary, payment.hasCouponApplied),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              payment.appliedCouponId > 0
                                  ? '${numberFormat.format(payment.couponDiscount)}원 할인'
                                  : '쿠폰 선택',
                              style: AppTextStyles.body2.copyWith(
                                color: colorUtil.getCouponTextColor(
                                    AppColors.primary,
                                    AppColors.darkGrey,
                                    payment.appliedCouponId > 0),
                                fontWeight: payment.appliedCouponId > 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 18.0,
                              color: colorUtil.getCouponIconColor(
                                  AppColors.primary,
                                  AppColors.grey,
                                  payment.appliedCouponId > 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (payment.appliedCouponId > 0) ...[
            const SizedBox(height: 8.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => paymentVM.removeCoupon(),
                child: Text(
                  '쿠폰 제거',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 수량 조절 버튼 위젯
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 32.0,
        height: 32.0,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(4.0),
          color: isEnabled ? Colors.white : AppColors.extraLightGrey,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16.0,
          color: isEnabled ? AppColors.darkGrey : AppColors.grey,
        ),
      ),
    );
  }
}
