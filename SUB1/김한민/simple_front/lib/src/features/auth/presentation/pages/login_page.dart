import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/social_login_button.dart';
import '../../../main/presentation/pages/main_page.dart';
import '../../domain/models/google_sign_in_result.dart';
import '../providers/auth_provider.dart';
import 'sign_up_page.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<GoogleSignInResult?>>(authStateProvider,
        (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

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
                    SocialLoginButton(
                      text: AppStrings.signUpWithGoogle,
                      iconPath: 'assets/images/google.png',
                      backgroundColor: AppColors.white,
                      onPressed: () async {
                        try {
                          final result = await ref
                              .read(authStateProvider.notifier)
                              .signInWithGoogle();

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpPage(
                                  accessToken: result.accessToken,
                                  serverAuthCode: result.serverAuthCode,
                                  email: result.email ?? '',
                                  name: result.name,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
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
                        // TODO: Implement Apple sign in
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
