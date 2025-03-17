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
  late final TextEditingController _birthdateController;
  String? _selectedGender; // ✅ 성별 선택 상태 추가

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
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _birthdateController.text =
            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
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
                /// 🔹 로고
                Text(
                  'SIMPLE',
                  style: AppTextStyles.logo.copyWith(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                /// 🔹 닉네임 입력
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: '닉네임',
                    filled: true,
                    fillColor: AppColors.lightGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? '닉네임을 입력해주세요' : null,
                ),
                const SizedBox(height: 16),

                /// 🔹 성별 선택 (남성 / 여성)
                Row(
                  children: [
                    Expanded(
                      child: _genderButton('남성'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _genderButton('여성'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                /// 🔹 생년월일 입력 (DatePicker)
                TextFormField(
                  controller: _birthdateController,
                  decoration: const InputDecoration(
                    labelText: '생년월일',
                    filled: true,
                    fillColor: AppColors.lightGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  readOnly: true,
                  onTap: _selectDate,
                ),
                const Spacer(),

                /// 🔹 가입하기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print('닉네임: ${_nicknameController.text}');
                        print('성별: $_selectedGender');
                        print('생년월일: ${_birthdateController.text}');
                        print('AccessToken: ${widget.accessToken}');
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

  /// 🔹 성별 선택 버튼 위젯
  Widget _genderButton(String gender) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : AppColors.lightGrey,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            gender,
            style: AppTextStyles.buttonText.copyWith(
              color: isSelected ? AppColors.primary : AppColors.darkGrey,
            ),
          ),
        ),
      ),
    );
  }
}
