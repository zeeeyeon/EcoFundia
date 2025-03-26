import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/shared/payment/domain/entities/payment_entity.dart';
import 'package:front/shared/payment/ui/viewmodels/payment_view_model.dart';
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
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductInfo(payment),
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
          borderRadius: BorderRadius.circular(10),
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
              const SizedBox(height: 4),
              Text(
                '${priceFormatter.format(payment.price)}원',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // 삭제 버튼
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.grey,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 12,
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
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGrey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 마이너스 버튼
              InkWell(
                onTap: () => viewModel.decrementQuantity(),
                child: Container(
                  width: 30,
                  height: 30,
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
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${payment.quantity}',
                  style: AppTextStyles.body1,
                ),
              ),

              // 플러스 버튼
              InkWell(
                onTap: () => viewModel.incrementQuantity(),
                child: Container(
                  width: 30,
                  height: 30,
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
          onTap: () => _showCouponDialog(context, viewModel),
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey),
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: Text(
              '쿠폰 사용',
              style: AppTextStyles.body2,
            ),
          ),
        ),
      ],
    );
  }

  /// 쿠폰 입력 다이얼로그
  void _showCouponDialog(BuildContext context, PaymentViewModel viewModel) {
    final couponController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '쿠폰 코드 입력',
          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: couponController,
          decoration: InputDecoration(
            hintText: '쿠폰 코드를 입력하세요',
            hintStyle: AppTextStyles.body2.copyWith(color: AppColors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: AppTextStyles.body2.copyWith(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              final couponCode = couponController.text.trim();
              if (couponCode.isNotEmpty) {
                viewModel.applyCoupon(couponCode);
              }
              Navigator.pop(context);
            },
            child: Text(
              '적용',
              style: AppTextStyles.body2.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
