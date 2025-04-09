import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/config/app_config.dart';
import 'package:front/core/services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/ui/widgets/social_login_button.dart';
import 'package:front/core/ui/widgets/loading_overlay.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/features/auth/providers/auth_providers.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    // 에러 발생 시 스낵바 표시
    if (appState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(appState.error!)),
          );
          ref.read(appStateProvider.notifier).clearError();
        }
      });
    }

    return LoadingOverlay(
      isLoading: appState.isLoading,
      message: '인증 처리 중...',
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkGrey),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            tooltip: '뒤로가기',
          ),
        ),
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(flex: 2),
                            Text(
                              AppStrings.appName,
                              style: AppTextStyles.logo,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SocialLoginButton(
                                  text: AppStrings.signUpWithGoogle,
                                  iconPath: 'assets/images/google.png',
                                  backgroundColor: AppColors.white,
                                  onPressed: () => ref
                                      .read(authProvider.notifier)
                                      .googleSignIn(),
                                ),
                                const SizedBox(height: 16),
                                SocialLoginButton(
                                  text: AppStrings.signUpWithApple,
                                  iconPath: 'assets/images/apple.png',
                                  backgroundColor: AppColors.primary,
                                  textColor: AppColors.white,
                                  onPressed: () {
                                    ApiService().get(const ApiEndpoints().test);
                                  },
                                ),
                              ],
                            ),
                            const Spacer(flex: 2),
                            Text(
                              '로그인 시 이용약관 및 개인정보 처리방침에 동의하게 됩니다.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
