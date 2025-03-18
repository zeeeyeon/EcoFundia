import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';

/// 전체 화면 로딩 오버레이
class LoadingOverlay extends StatelessWidget {
  final Widget? child;
  final bool isLoading;
  final String? message;
  final Color? backgroundColor;
  final Color? progressColor;
  final double? size;

  const LoadingOverlay({
    super.key,
    this.child,
    required this.isLoading,
    this.message,
    this.backgroundColor,
    this.progressColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null) child!,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: size ?? 50,
                    height: size ?? 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progressColor ?? AppColors.primary,
                      ),
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// 전체 화면 로딩 오버레이를 표시하는 정적 메서드
  static void show(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => WillPopScope(
        onWillPop: () async => barrierDismissible,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 로딩 오버레이를 숨기는 정적 메서드
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
