import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/features/mypage/domain/entities/coupon_entity.dart';
import 'package:front/shared/payment/domain/providers/payment_providers.dart';
import 'package:intl/intl.dart';

/// 쿠폰 선택 다이얼로그
class CouponDialog extends ConsumerWidget {
  /// 쿠폰 선택 콜백 - 쿠폰 ID를 반환하도록 수정
  final Function(int couponId, int discountAmount) onCouponSelected;

  const CouponDialog({
    Key? key,
    required this.onCouponSelected,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required Function(int couponId, int discountAmount) onCouponSelected,
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
  Widget build(BuildContext context, WidgetRef ref) {
    // 사용 가능한 쿠폰 목록을 가져옵니다.
    final availableCouponsAsync = ref.watch(availableCouponsProvider);

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
          ),
          const Divider(height: 1, color: AppColors.lightGrey),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 400,
              minHeight: 200,
            ),
            child: availableCouponsAsync.when(
              data: (coupons) {
                if (coupons.isEmpty) {
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

                    return InkWell(
                      onTap: () {
                        onCouponSelected(
                            coupon.couponId, coupon.discountAmount);
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
                              '${NumberFormat('#,##0').format(coupon.discountAmount)}원',
                              style: AppTextStyles.body1.copyWith(
                                color: AppColors.primary,
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
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    '쿠폰 정보를 불러올 수 없습니다.\n${error.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
