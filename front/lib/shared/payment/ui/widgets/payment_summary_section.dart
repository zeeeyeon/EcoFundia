import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/shared/payment/domain/entities/payment_entity.dart';
import 'package:front/shared/payment/presentation/viewmodels/payment_view_model.dart';
import 'package:intl/intl.dart';

/// 결제 요약 섹션 위젯
class PaymentSummarySection extends ConsumerWidget {
  const PaymentSummarySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentViewModelProvider);
    final payment = state.payment;

    if (payment == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // 총 상품 금액
        _buildPriceItem(
          label: '총 상품 금액',
          amount: payment.totalProductPrice,
          backgroundColor: AppColors.extraLightGrey.withOpacity(0.7),
        ),

        // 쿠폰 할인 금액 (있는 경우에만 표시)
        if (payment.couponDiscount > 0)
          _buildPriceItem(
            label: '쿠폰',
            amount: -payment.couponDiscount,
            backgroundColor: Colors.white.withOpacity(0.7),
            border: Border.all(color: AppColors.lightGrey),
          ),
      ],
    );
  }

  /// 가격 항목 UI
  Widget _buildPriceItem({
    required String label,
    required int amount,
    Color? backgroundColor,
    BoxBorder? border,
  }) {
    final priceFormatter = NumberFormat('#,##0');
    final isDiscount = amount < 0;

    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 라벨
          Text(
            label,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          // 금액
          Text(
            '${isDiscount ? '- ' : ''}${priceFormatter.format(isDiscount ? -amount : amount)}원',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
