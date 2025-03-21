import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';

/// 빈 위시리스트 위젯
/// 해당 카테고리에 위시리스트 아이템이 없을 때 표시
class EmptyWishlist extends StatelessWidget {
  final String message;

  const EmptyWishlist({
    super.key,
    this.message = '위시리스트가 비어있습니다.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 70,
            color: AppColors.border,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
