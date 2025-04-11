import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';

/// 공통 에러 다이얼로그
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;

  const ErrorDialog({
    super.key,
    this.title = '오류 발생',
    required this.message,
    this.onConfirm,
  });

  /// 다이얼로그를 표시하는 정적 메서드
  static Future<void> show(
    BuildContext context, {
    String title = '오류 발생',
    required String message,
    VoidCallback? onConfirm,
  }) {
    // 비어있는 메시지는 표시하지 않음
    if (message.isEmpty) {
      return Future.value();
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 배경 탭으로 닫기 비활성화
      builder: (BuildContext dialogContext) {
        return ErrorDialog(
          title: title,
          message: message,
          onConfirm: onConfirm ?? () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
      actionsPadding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      title: Text(title, style: AppTextStyles.heading3),
      content: Text(
        message,
        style: AppTextStyles.body1.copyWith(color: AppColors.textDark),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: onConfirm ?? () => Navigator.of(context).pop(),
          child: Text('확인', style: AppTextStyles.buttonText),
        ),
      ],
    );
  }
}
