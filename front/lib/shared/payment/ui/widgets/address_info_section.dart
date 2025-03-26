import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/shared/payment/domain/entities/payment_entity.dart';
import 'package:front/shared/payment/ui/viewmodels/payment_view_model.dart';

/// 배송 정보 섹션 위젯
class AddressInfoSection extends ConsumerWidget {
  const AddressInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentViewModelProvider);
    final payment = state.payment;

    if (payment == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildRecipientInfo(payment),
          const Divider(height: 1, color: AppColors.lightGrey),
          _buildAddressInfo(payment),
          const Divider(height: 1, color: AppColors.lightGrey),
          _buildPhoneInfo(payment),
        ],
      ),
    );
  }

  /// 수령인 정보
  Widget _buildRecipientInfo(PaymentEntity payment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 수령인 이름
          Row(
            children: [
              Text(
                payment.recipientName,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // 기본 배송지 표시
          if (payment.isDefaultAddress)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '기본 배송지',
                style: AppTextStyles.body2.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 주소 정보
  Widget _buildAddressInfo(PaymentEntity payment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        payment.address,
        style: AppTextStyles.body2.copyWith(
          color: AppColors.darkGrey,
        ),
      ),
    );
  }

  /// 연락처 정보
  Widget _buildPhoneInfo(PaymentEntity payment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        payment.phoneNumber,
        style: AppTextStyles.body1.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
