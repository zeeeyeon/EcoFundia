import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/ui/widgets/social_login_button.dart';
import 'package:front/features/auth/ui/view_model/auth_provider.dart';
import 'package:front/utils/logger_util.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LoggerUtil.i('📱 LoginPage 빌드 시작');

    // 페이지 전환 시 상태 초기화를 위한 provider 감시
    ref.watch(authStateResetProvider);
    LoggerUtil.d('🔄 상태 초기화 Provider 감시 중');

    // 인증 상태 감시
    final authState = ref.watch(authProvider);
    LoggerUtil.d(
        '👀 현재 인증 상태: isLoggedIn=${authState.isLoggedIn}, isNewUser=${authState.isNewUser}, isLoading=${authState.isLoading}');

    // 에러 발생 시 스낵바 표시
    if (authState.error != null) {
      LoggerUtil.w('⚠️ 에러 발생: ${authState.error}');
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.error!)),
        );
        ref.read(authProvider.notifier).clearError();
      });
    }

    // 이미 로그인되어 있으면 홈으로 이동
    if (authState.isLoggedIn) {
      LoggerUtil.i('✅ 로그인 상태 확인: 이미 로그인됨, 홈으로 이동');
      Future.microtask(() => context.go('/'));
    }

    // 신규 사용자면 회원가입 페이지로 이동
    if (authState.isNewUser) {
      LoggerUtil.i('📝 신규 사용자 확인: 회원가입 페이지로 이동');
      Future.microtask(() => context.go('/signup'));
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 324),
              Text(
                AppStrings.appName,
                style: AppTextStyles.logo,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (authState.isLoading)
                      const CircularProgressIndicator()
                    else
                      SocialLoginButton(
                        text: AppStrings.signUpWithGoogle,
                        iconPath: 'assets/images/google.png',
                        backgroundColor: AppColors.white,
                        onPressed: () {
                          LoggerUtil.i('🔘 Google 로그인 버튼 클릭');
                          ref.read(authProvider.notifier).signInWithGoogle();
                        },
                      ),
                    const SizedBox(height: 16),
                    SocialLoginButton(
                      text: AppStrings.signUpWithApple,
                      iconPath: 'assets/images/apple.png',
                      backgroundColor: AppColors.primary,
                      textStyle: AppTextStyles.appleButtonText,
                      onPressed: () {
                        LoggerUtil.i('🔘 Apple 로그인 버튼 클릭 (미구현)');
                        // TODO: Implement Apple sign in
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  '로그인 시 이용약관 및 개인정보 처리방침에 동의하게 됩니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
