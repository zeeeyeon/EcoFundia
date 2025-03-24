import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FundingStatusCard extends StatelessWidget {
  final int totalFundingAmount;
  final int couponCount;

  const FundingStatusCard({
    super.key,
    required this.totalFundingAmount,
    required this.couponCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          children: [
            // 펀딩현황 (클릭 없음)
            Expanded(
              child: _buildStatusItem(
                "펀딩현황",
                "$totalFundingAmount원",
                highlight: true,
              ),
            ),

            // 구분선
            Container(
              width: 2,
              height: 55,
              color: Colors.grey.shade300,
            ),

            // 쿠폰 (클릭 시 이동 + 밑줄 표시)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context.push('/coupons');
                },
                child: _buildStatusItem(
                  "쿠폰",
                  "$couponCount장",
                  highlight: true,
                  underline: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    String title,
    String value, {
    bool highlight = false,
    bool underline = false,
  }) {
    final RegExp regex = RegExp(r'(\d+)([^\d]*)');
    final match = regex.firstMatch(value);

    final numberPart = match?.group(1) ?? value;
    final unitPart = match?.group(2) ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: numberPart,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: highlight ? Colors.green : Colors.black87,
                    decoration: underline
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),
                TextSpan(
                  text: unitPart,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
