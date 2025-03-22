import 'package:flutter/material.dart';

/// 앱에서 사용되는 공통 다이얼로그 컴포넌트
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = '확인',
    this.cancelText = '취소',
    this.onConfirm,
    this.onCancel,
    this.isDismissible = true,
    this.type = AppDialogType.alert,
  });

  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDismissible;
  final AppDialogType type;

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = '확인',
    String cancelText = '취소',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDismissible = true,
    AppDialogType type = AppDialogType.alert,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDismissible: isDismissible,
        type: type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => isDismissible,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case AppDialogType.success:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case AppDialogType.error:
        iconData = Icons.error;
        iconColor = Colors.red;
        break;
      case AppDialogType.warning:
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
      case AppDialogType.info:
        iconData = Icons.info;
        iconColor = Colors.blue;
        break;
      case AppDialogType.alert:
        iconData = Icons.help;
        iconColor = Colors.grey;
        break;
    }

    return Icon(
      iconData,
      size: 48,
      color: iconColor,
    );
  }

  Widget _buildButtons(BuildContext context) {
    if (type == AppDialogType.alert) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                onCancel?.call();
                Navigator.of(context).pop(false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
              ),
              child: Text(cancelText),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                onConfirm?.call();
                Navigator.of(context).pop(true);
              },
              child: Text(confirmText),
            ),
          ),
        ],
      );
    }

    return ElevatedButton(
      onPressed: () {
        onConfirm?.call();
        Navigator.of(context).pop(true);
      },
      child: Text(confirmText),
    );
  }
}

enum AppDialogType {
  success,
  error,
  warning,
  info,
  alert,
}
