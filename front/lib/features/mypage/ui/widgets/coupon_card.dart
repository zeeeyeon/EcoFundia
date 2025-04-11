import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/features/mypage/domain/entities/coupon_entity.dart';
import 'package:front/utils/date_format_util.dart';

class CouponCard extends StatelessWidget {
  final CouponEntity coupon;

  const CouponCard({super.key, required this.coupon});

  @override
  Widget build(BuildContext context) {
    final isValid =
        !coupon.isUsed && DateFormatUtil.isDateValid(coupon.expirationDate);
    final borderColor = isValid ? AppColors.primary : Colors.grey;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 쿠폰 상단 부분 - 할인율/금액 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: isValid
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 할인 정보
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCouponTitle(coupon),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getCouponTypeText(coupon),
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),

                // 사용 가능 여부 표시
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isValid ? AppColors.primary : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isValid ? '사용 가능' : '사용 완료',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 쿠폰 하단 부분 - 상세 정보
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 최소 주문 금액
                _buildInfoRow(
                  '최소 주문금액:',
                  coupon.minOrderAmount > 0
                      ? DateFormatUtil.formatCurrency(coupon.minOrderAmount)
                      : '제한 없음',
                ),
                const SizedBox(height: 4),

                // 유효 기간
                _buildInfoRow(
                  '유효기간:',
                  '~ ${DateFormatUtil.formatYYYYMMDD(coupon.expirationDate)}',
                ),
                const SizedBox(height: 8),

                // 설명
                if (coupon.description.isNotEmpty)
                  Text(
                    coupon.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 쿠폰 타입에 따른 타이틀 반환
  String _getCouponTitle(CouponEntity coupon) {
    if (coupon.type == 'PERCENTAGE') {
      return '${coupon.discountRate}% 할인';
    } else {
      return DateFormatUtil.formatCurrency(coupon.discountAmount);
    }
  }

  // 쿠폰 타입에 따른 서브타이틀 반환
  String _getCouponTypeText(CouponEntity coupon) {
    if (coupon.type == 'PERCENTAGE') {
      // 최대 할인 금액이 있는 경우
      if (coupon.maxDiscountAmount > 0) {
        return '최대 ${DateFormatUtil.formatCurrency(coupon.maxDiscountAmount)}까지';
      } else {
        return '비율 할인 쿠폰';
      }
    } else {
      return '금액 할인 쿠폰';
    }
  }

  // 정보 한 줄을 표시하는 위젯
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
