import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final TextStyle? textStyle;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.iconPath,
    required this.backgroundColor,
    required this.onPressed,
    this.textColor = AppColors.textGrey,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColorLight,
            offset: Offset(0, 2),
            blurRadius: 3,
          ),
          BoxShadow(
            color: AppColors.shadowColor,
            offset: Offset(0, 0),
            blurRadius: 3,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  iconPath,
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 15),
                Text(
                  text,
                  style: textStyle ?? AppTextStyles.buttonText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
