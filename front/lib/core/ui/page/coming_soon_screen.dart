import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/ui/widgets/custom_app_bar.dart'; // Use CustomAppBar for consistency

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: '안내', // Simple title
        showBackButton: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction_outlined, // Construction icon
              size: 60,
              color: AppColors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              '서비스 준비 중입니다',
              style: AppTextStyles.heading4.copyWith(color: AppColors.textDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '보다 나은 서비스 제공을 위해 페이지를 준비하고 있습니다.\n빠른 시일 내에 찾아뵙겠습니다.',
              style: AppTextStyles.body2.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
