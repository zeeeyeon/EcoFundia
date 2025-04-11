import 'package:flutter/material.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/constants/app_sizes.dart';

/// 오류 메시지 표시를 위한 공통 위젯
///
/// 오류 메시지와 선택적으로 재시도 버튼을 표시합니다.
/// isNetworkError 속성을 통해 네트워크 오류인 경우 다른 아이콘과 색상을 사용합니다.
class ErrorMessageWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool isNetworkError;

  const ErrorMessageWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon,
    this.isNetworkError = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 네트워크 오류인 경우와 일반 오류에 따라 다른 아이콘과 색상 사용
    final IconData displayIcon =
        icon ?? (isNetworkError ? Icons.wifi_off : Icons.error_outline);
    final Color iconColor =
        isNetworkError ? AppColors.warning : AppColors.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              displayIcon,
              size: AppSizes.iconL,
              color: iconColor,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              message,
              style: isNetworkError
                  ? AppTextStyles.body.copyWith(color: AppColors.darkGrey)
                  : AppTextStyles.errorText,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.paddingL),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isNetworkError ? AppColors.primary : AppColors.error,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingL,
                    vertical: AppSizes.paddingM / 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
