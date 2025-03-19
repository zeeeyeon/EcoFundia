import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/ui/widgets/social_login_button.dart';
import 'package:front/core/ui/widgets/loading_overlay.dart';
import 'package:front/features/auth/domain/models/auth_result.dart';
import 'package:front/features/auth/ui/view_model/auth_provider.dart';
import 'package:front/utils/logger_util.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    LoggerUtil.i('📱 LoginScreen 초기화');
  }

  @override
  Widget build(BuildContext context) {
    LoggerUtil.i('📱 LoginScreen 빌드 시작');

    // 페이지 전환 시 상태 초기화를 위한 provider 감시
    ref.watch(authStateResetProvider);
    LoggerUtil.d('🔄 상태 초기화 Provider 감시 중');

    // 인증 상태 감시
    final authState = ref.watch(authProvider);
    final authViewModel = ref.read(authProvider.notifier);

    LoggerUtil.d(
        '👀 현재 인증 상태: isLoggedIn=${authState.isLoggedIn}, isLoading=${authState.isLoading}');

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/home');
        }
      });
    }

    return LoadingOverlay(
      isLoading: authState.isLoading,
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
                          LoggerUtil.i('🔘 Google 로그인 버튼 클릭');
                          final result = await authViewModel.signInWithGoogle();

                          if (!mounted) return;

                          if (result is AuthSuccess) {
                            LoggerUtil.i('✅ 로그인 성공, 홈으로 이동');
                            context.go('/home');
                          } else if (result is AuthError) {
                            LoggerUtil.e('❌ 로그인 실패: ${result.message}');
                            // 에러 처리는 상태 변화로 자동으로 처리됨
                          } else if (result is AuthCancelled) {
                            LoggerUtil.w('⚠️ 로그인 취소됨');
                          } else if (result is AuthNewUser) {
                            LoggerUtil.i('📝 신규 사용자 감지: 회원가입 페이지로 이동');
                            try {
                              final userData =
                                  await authViewModel.getLastUserInfo();
                              LoggerUtil.i('✅ 사용자 정보 획득 완료: ${userData.keys}');
                              if (!mounted) return;

                              // 상태 업데이트를 기다린 후 페이지 전환
                              await Future.delayed(
                                  const Duration(milliseconds: 100));
                              if (!mounted) return;

                              // 에러 메시지를 표시하지 않고 바로 회원가입 페이지로 이동
                              context.go('/signup', extra: userData);
                            } catch (e) {
                              LoggerUtil.e('❌ 사용자 정보 획득 실패', e);
                              if (!mounted) return;
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
      ),
    );
  }
}
