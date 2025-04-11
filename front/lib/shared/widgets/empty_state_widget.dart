import 'package:flutter/material.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/themes/app_colors.dart';

/// 빈 상태(데이터가 없는 상태)를 표시하기 위한 공통 위젯
///
/// 메시지와 선택적으로 아이콘을 표시합니다.
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;

  const EmptyStateWidget({
    Key? key,
    required this.message,
    this.icon,
    this.iconSize = 48.0,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? AppColors.grey,
              ),
            if (icon != null) const SizedBox(height: 16.0),
            Text(
              message,
              style: AppTextStyles.emptyMessage,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
