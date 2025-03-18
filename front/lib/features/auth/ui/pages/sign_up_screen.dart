import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/features/auth/ui/widgets/custom_text_field.dart';
import 'package:front/features/auth/domain/use_cases/validators_use_case.dart';
import 'package:front/features/auth/ui/view_model/sign_up_view_model.dart';
import 'package:front/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:front/utils/logger_util.dart';
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

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('성별을 선택해주세요.')),
      );
      return;
    }

    try {
      final result = await ref.read(signUpProvider.notifier).completeSignUp(
            email: widget.email,
            nickname: _nicknameController.text,
            gender: _selectedGender!,
            age: int.parse(_ageController.text),
            serverAuthCode: widget.serverAuthCode,
          );

      if (result is AuthSuccess) {
        if (mounted) {
          context.go('/signup/complete', extra: _nicknameController.text);
        }
      } else if (result is AuthError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message)),
          );
        }
      }
    } catch (e) {
      LoggerUtil.e('❌ 회원가입 중 오류 발생', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 중 오류가 발생했습니다.')),
        );
      }
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

    return Scaffold(
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

                /// 성별 (남성 / 여성)
                Row(
                  children: [
                    Expanded(child: _genderButton('남성')),
                    const SizedBox(width: 16),
                    Expanded(child: _genderButton('여성')),
                  ],
                ),
                const SizedBox(height: 16),

                /// 나이 입력 (숫자, 2자리, 19~99)
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
                    child: signUpState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white),
                            ),
                          )
                        : Text(
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
    );
  }

  /// 성별 선택 버튼 위젯
  Widget _genderButton(String gender) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : AppColors.textFieldColor,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textFieldColor,
            width: isSelected ? 2.0 : 0.0,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            gender,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.darkGrey,
            ),
          ),
        ),
      ),
    );
  }
}
