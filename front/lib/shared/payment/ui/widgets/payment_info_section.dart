import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/shared/payment/ui/view_model/payment_view_model.dart';
import 'package:intl/intl.dart';

/// 결제 금액 요약 섹션 위젯
class PaymentInfoSection extends ConsumerWidget {
  const PaymentInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentViewModelProvider);
    final payment = state.payment;

    if (payment == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final NumberFormat formatter = NumberFormat('#,##0');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 상품 금액
          _buildPriceRow(
            label: '상품 금액',
            amount: payment.totalProductPrice,
            formatter: formatter,
          ),
          const SizedBox(height: 12),

          // 할인 금액
          _buildPriceRow(
            label: '할인 금액',
            amount: -payment.couponDiscount,
            formatter: formatter,
            valueColor: AppColors.primary,
          ),
          const SizedBox(height: 12),

          // 구분선
          const Divider(color: AppColors.lightGrey),
          const SizedBox(height: 12),

          // 최종 결제 금액
          _buildPriceRow(
            label: '최종 결제 금액',
            amount: payment.finalAmount,
            formatter: formatter,
            labelStyle: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
            valueStyle: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// 가격 정보 행 위젯
  Widget _buildPriceRow({
    required String label,
    required int amount,
    required NumberFormat formatter,
    Color? valueColor,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    // 음수인 경우 처리 (할인 금액)
    final isNegative = amount < 0;
    final displayAmount = isNegative ? amount.abs() : amount;
    final prefix = isNegative ? '-' : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ?? AppTextStyles.body2,
        ),
        Text(
          '$prefix${formatter.format(displayAmount)}원',
          style: valueStyle ??
              AppTextStyles.body1.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
