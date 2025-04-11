import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/ui/widgets/loading_overlay.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/features/auth/ui/widgets/custom_text_field.dart';
import 'package:front/features/auth/ui/widgets/gender_selection.dart';
import 'package:front/utils/sign_up_validator.dart';
import 'package:front/features/auth/domain/entities/auth_result_entity.dart';
import 'package:front/features/auth/ui/view_model/sign_up_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/ui/widgets/custom_button.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  final String? token;
  final String email;
  final String? name;

  const SignUpScreen({
    super.key,
    this.token,
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

  /// 회원가입 처리
  Future<void> _handleSignUp(BuildContext context, WidgetRef ref) async {
    // 키보드 감추기
    FocusScope.of(context).unfocus();

    // 입력값 검증
    if (_formKey.currentState!.validate()) {
      try {
        // SignUpViewModel에서 회원가입 실행
        final result = await ref.read(signUpProvider.notifier).signUp(
              email: widget.email,
              nickname: _nicknameController.text.trim(),
              gender: _selectedGender ?? 'MALE',
              age: int.parse(_ageController.text.trim()),
              token: widget.token,
            );

        if (!context.mounted) return;

        // 결과 처리
        if (result is AuthSuccessEntity) {
          // 회원가입 성공 - 완료 화면으로 이동
          context.goNamed(
            'signup-complete',
            extra: {'nickname': _nicknameController.text.trim()},
          );
        } else if (result is AuthErrorEntity) {
          // 에러 처리
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message)),
          );
        }
      } catch (e) {
        if (!context.mounted) return;

        // 예외 처리
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 처리 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);

    // 에러 발생 시 스낵바 표시
    if (appState.error.isNotEmpty) {
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appState.error)),
        );
        ref.read(appStateProvider.notifier).clearError();
      });
    }

    return LoadingOverlay(
      isLoading: appState.isLoading,
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
                    validator: SignUpValidator.validateNickname,
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
                    hintText: '나이',
                    keyboardType: TextInputType.number,
                    validator: SignUpValidator.validateAge,
                  ),
                  const Spacer(),

                  /// 회원가입 버튼
                  CustomButton(
                    text: '가입하기',
                    backgroundColor: AppColors.primary,
                    onPressed: () => _handleSignUp(context, ref),
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
