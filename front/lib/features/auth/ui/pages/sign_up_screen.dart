import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/ui/widgets/loading_overlay.dart';
import 'package:front/features/auth/ui/widgets/custom_text_field.dart';
import 'package:front/features/auth/ui/widgets/gender_selection.dart';
import 'package:front/features/auth/domain/use_cases/validators_use_case.dart';
import 'package:front/features/auth/ui/view_model/sign_up_view_model.dart';
import 'package:front/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  final String? serverAuthCode;
  final String email;
  final String? name;

  const SignUpScreen({
    super.key,
    this.serverAuthCode,
    required this.email,
    this.name,
  });

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late final TextEditingController _ageController;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.name);
    _ageController = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final result = await ref.read(signUpProvider.notifier).signUp(
            email: widget.email,
            nickname: _nicknameController.text,
            gender: _selectedGender!,
            age: _ageController.text,
            serverAuthCode: widget.serverAuthCode,
          );

      if (mounted) {
        if (result is AuthSuccess) {
          context.go('/signup-success', extra: _nicknameController.text);
        }
      }
    } catch (e) {
      // 에러 처리는 ViewModel에서 처리되므로 여기서는 추가 처리가 필요 없음
    }
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpProvider);

    // 에러 발생 시 스낵바 표시
    if (signUpState.error != null) {
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(signUpState.error!)),
        );
        ref.read(signUpProvider.notifier).clearError();
      });
    }

    return LoadingOverlay(
      isLoading: signUpState.isLoading,
      message: '회원가입 처리 중...',
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkGrey),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.appName,
                    style: AppTextStyles.logo.copyWith(fontSize: 48),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  /// 닉네임 입력
                  CustomTextField(
                    controller: _nicknameController,
                    hintText: '닉네임',
                    validator: InputValidators.validateNickname,
                  ),
                  const SizedBox(height: 16),

                  /// 성별 선택
                  GenderSelection(
                    initialValue: _selectedGender,
                    onChanged: (value) =>
                        setState(() => _selectedGender = value),
                  ),
                  const SizedBox(height: 16),

                  /// 나이 입력
                  CustomTextField(
                    controller: _ageController,
                    hintText: '나이 (ex: 만 25)',
                    keyboardType: TextInputType.number,
                    validator: InputValidators.validateAge,
                  ),
                  const Spacer(),

                  /// 가입하기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: signUpState.isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '가입하기',
                        style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
