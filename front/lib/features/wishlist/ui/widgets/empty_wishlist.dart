import 'package:flutter/material.dart';

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
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
