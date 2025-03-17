import 'package:flutter/material.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';

class SignUpScreen extends StatefulWidget {
  // final String accessToken;  // 필요 시 다시 사용
  final String? serverAuthCode;
  final String email;
  final String? name;

  const SignUpScreen({
    super.key,
    // required this.accessToken,
    this.serverAuthCode,
    required this.email,
    this.name,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late final TextEditingController _birthdateController;
  String? _selectedGender; // 성별: '남성' 또는 '여성' 저장

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.name);
    _birthdateController = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        // YYYY-MM-DD 형식
        _birthdateController.text =
            '${pickedDate.year}-${pickedDate.month}-${pickedDate.day}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _buildTextField(
                  controller: _nicknameController,
                  hintText: '닉네임',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '닉네임을 입력해주세요';
                    }
                    return null;
                  },
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

                /// 생년월일
                _buildTextField(
                  controller: _birthdateController,
                  hintText: '생년월일',
                  readOnly: true,
                  onTap: _selectDate,
                ),

                // Spacer로 남은 공간 밀어냄
                const Spacer(),

                /// 가입하기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        debugPrint('닉네임: ${_nicknameController.text}');
                        debugPrint('성별: $_selectedGender');
                        debugPrint('생년월일: ${_birthdateController.text}');
                        // debugPrint('AccessToken: ${widget.accessToken}');
                      }
                    },
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
    );
  }

  /// 공통 텍스트필드 빌더
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
    Function()? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        // 채워지는 배경색
        filled: true,
        fillColor: AppColors.lightGrey,
        // 필드 내부 힌트
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.darkGrey,
          fontSize: 18,
        ),
        // 테두리 스타일
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, // 기본은 없음
        ),
        // 여백
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
          color: isSelected ? AppColors.white : AppColors.lightGrey,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
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
