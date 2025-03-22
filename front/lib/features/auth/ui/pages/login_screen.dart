import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/ui/widgets/social_login_button.dart';
import 'package:front/core/ui/widgets/loading_overlay.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/features/auth/domain/models/auth_result.dart';
import 'package:front/features/auth/ui/view_model/auth_provider.dart';
import 'package:front/utils/logger_util.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);
    final appState = ref.watch(appStateProvider);
    final authViewModel = ref.read(authProvider.notifier);

    // 에러 발생 시 스낵바 표시
    if (appState.error != null) {
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appState.error!)),
        );
        ref.read(appStateProvider.notifier).clearError();
      });
    }

    // 이미 로그인되어 있으면 홈으로 이동
    if (isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/');
        }
      });
    }

    return LoadingOverlay(
      isLoading: appState.isLoading,
      message: '로그인 중...',
      child: Scaffold(
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
                      SocialLoginButton(
                        text: AppStrings.signUpWithGoogle,
                        iconPath: 'assets/images/google.png',
                        backgroundColor: AppColors.white,
                        onPressed: () async {
                          final result = await authViewModel.signInWithGoogle();

                          if (!context.mounted) return;

                          if (result is AuthSuccess) {
                            LoggerUtil.i('로그인 성공');
                            context.go('/');
                          } else if (result is AuthNewUser) {
                            try {
                              final userData =
                                  await authViewModel.getLastUserInfo();
                              if (!context.mounted) return;

                              await Future.delayed(
                                  const Duration(milliseconds: 100));
                              if (!context.mounted) return;

                              context.go('/signup', extra: userData);
                            } catch (e) {
                              LoggerUtil.e('회원가입 정보 획득 실패', e);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('회원가입 정보를 가져오는데 실패했습니다.'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      SocialLoginButton(
                        text: AppStrings.signUpWithApple,
                        iconPath: 'assets/images/apple.png',
                        backgroundColor: AppColors.primary,
                        textColor: AppColors.white,
                        onPressed: () {
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
      ),
    );
  }
}
