import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/shared/dummy/data/coupon_dummy.dart';
import 'package:intl/intl.dart';

/// 쿠폰 선택 다이얼로그
class CouponDialog extends StatelessWidget {
  /// 쿠폰 선택 콜백
  final Function(String couponCode) onCouponSelected;

  const CouponDialog({
    Key? key,
    required this.onCouponSelected,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required Function(String couponCode) onCouponSelected,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CouponDialog(
        onCouponSelected: onCouponSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '쿠폰',
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
          ),
          const Divider(height: 1, color: AppColors.lightGrey),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 400,
              minHeight: 200,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: couponDummyList.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: AppColors.lightGrey,
              ),
              itemBuilder: (context, index) {
                final coupon = couponDummyList[index];

                return InkWell(
                  onTap: () {
                    onCouponSelected(coupon.code);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.name,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${NumberFormat('#,##0').format(coupon.amount)}원',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${coupon.expiryDate}까지 사용 가능',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
