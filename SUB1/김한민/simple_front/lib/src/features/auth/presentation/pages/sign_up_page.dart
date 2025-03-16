import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SignUpPage extends StatefulWidget {
  final String accessToken;
  final String? serverAuthCode;
  final String email;
  final String? name;

  const SignUpPage({
    super.key,
    required this.accessToken,
    this.serverAuthCode,
    required this.email,
    this.name,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(AppStrings.signUpTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.welcome,
                  style: AppTextStyles.logo.copyWith(
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.signUpDescription,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.nickname,
                    hintText: AppStrings.nicknameHint,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '닉네임을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                    border: OutlineInputBorder(),
                  ),
                  enabled: false, // 이메일은 수정 불가
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: 회원가입 API 호출
                        print('AccessToken: ${widget.accessToken}');
                        print('ServerAuthCode: ${widget.serverAuthCode}');
                        print('Email: ${widget.email}');
                        print('Nickname: ${_nicknameController.text}');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      AppStrings.next,
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.white,
                      ),
                    ),
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
