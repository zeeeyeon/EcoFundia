import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:go_router/go_router.dart';

/// 결제 완료 페이지
class PaymentCompletePage extends StatelessWidget {
  const PaymentCompletePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 텍스트와 아이콘이 화면 중앙에 오도록 Expanded 사용
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 성공 아이콘
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 100,
                      ),
                      const SizedBox(height: 32),
                      // 제목
                      Text(
                        '펀딩 참여가 완료되었습니다',
                        style: AppTextStyles.body1.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // 서브 텍스트
                      Text(
                        '펀딩에 참여해 주셔서 감사합니다.\n친환경 프로젝트 성공에 기여하셨습니다.',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.grey,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // 하단에 고정된 버튼
              ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '홈으로 돌아가기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
