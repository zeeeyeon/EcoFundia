import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:intl/intl.dart';

/// 결제 확인 다이얼로그 위젯
class PaymentConfirmDialog extends StatelessWidget {
  /// 결제 금액
  final int amount;

  /// 취소 버튼 콜백
  final VoidCallback onCancel;

  /// 확인 버튼 콜백
  final VoidCallback onConfirm;

  const PaymentConfirmDialog({
    Key? key,
    required this.amount,
    required this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0');

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        '결제 확인',
        style: AppTextStyles.body1.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),

          // 결제 금액 표시
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.body1.copyWith(
                fontSize: 16,
                color: Colors.black,
              ),
              children: [
                const TextSpan(text: '총 '),
                TextSpan(
                  text: '${formatter.format(amount)}원',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const TextSpan(text: '을\n결제하시겠습니까?'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 안내 메시지
          Text(
            '결제 시 등록된 결제 수단으로 진행됩니다.',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.grey,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        // 취소 버튼
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: AppColors.lightGrey),
            ),
            child: Text(
              '취소',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // 확인 버튼
        Expanded(
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '확인',
              style: AppTextStyles.body2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
