import 'package:flutter/material.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/constants/app_sizes.dart';

/// 오류 메시지 표시를 위한 공통 위젯
///
/// 오류 메시지와 선택적으로 재시도 버튼을 표시합니다.
class ErrorMessageWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorMessageWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSizes.iconL,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              message,
              style: AppTextStyles.errorText,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.paddingM),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
