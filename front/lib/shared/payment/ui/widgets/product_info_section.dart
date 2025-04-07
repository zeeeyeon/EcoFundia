import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/shared/payment/domain/entities/payment_entity.dart';
import 'package:front/shared/payment/ui/view_model/payment_view_model.dart';
import 'package:front/shared/payment/ui/widgets/coupon_dialog.dart';
import 'package:intl/intl.dart';

/// 상품 정보 섹션 위젯
class ProductInfoSection extends ConsumerWidget {
  const ProductInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentViewModelProvider);
    final viewModel = ref.read(paymentViewModelProvider.notifier);
    final payment = state.payment;

    if (payment == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductInfo(payment),
          const SizedBox(height: 16),
          const Divider(color: AppColors.lightGrey),
          const SizedBox(height: 16),
          _buildQuantityAndCoupon(context, payment, viewModel),
        ],
      ),
    );
  }

  /// 상품 정보 UI
  Widget _buildProductInfo(PaymentEntity payment) {
    final priceFormatter = NumberFormat('#,###');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상품 이미지
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
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
                  color: AppColors.extraLightGrey,
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // 상품 정보
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
              const SizedBox(height: 4),
              Text(
                payment.productName,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${priceFormatter.format(payment.price)}원',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 수량 조절과 쿠폰 사용 UI
  Widget _buildQuantityAndCoupon(
      BuildContext context, PaymentEntity payment, PaymentViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 수량 조절 UI
        Container(
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGrey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 마이너스 버튼
              InkWell(
                onTap: () => viewModel.decrementQuantity(),
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.remove,
                    size: 16,
                  ),
                ),
              ),

              // 수량 표시
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${payment.quantity}',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 플러스 버튼
              InkWell(
                onTap: () => viewModel.incrementQuantity(),
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.add,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 쿠폰 버튼
        InkWell(
          onTap: () => CouponDialog.show(
            context: context,
            onCouponSelected: (couponId, discountAmount) {
              viewModel.applyCouponWithId(couponId, discountAmount);
            },
          ),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: payment.hasCouponApplied
                    ? AppColors.primary
                    : AppColors.lightGrey,
              ),
              borderRadius: BorderRadius.circular(8),
              color: payment.hasCouponApplied
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.white,
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  payment.hasCouponApplied
                      ? Icons.local_activity
                      : Icons.local_activity_outlined,
                  size: 16,
                  color: payment.hasCouponApplied
                      ? AppColors.primary
                      : AppColors.darkGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  payment.hasCouponApplied
                      ? '${NumberFormat('#,###').format(payment.couponDiscount)}원 할인'
                      : '쿠폰 사용',
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: payment.hasCouponApplied
                        ? AppColors.primary
                        : AppColors.darkGrey,
                  ),
                ),
                if (payment.hasCouponApplied) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // 이벤트 전파 방지
                      viewModel.removeCoupon();
                    },
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
