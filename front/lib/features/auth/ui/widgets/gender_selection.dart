import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/utils/sign_up_validator.dart';

class GenderSelection extends FormField<String> {
  GenderSelection({
    super.key,
    String? initialValue,
    required ValueChanged<String?> onChanged,
  }) : super(
          initialValue: initialValue,
          validator: SignUpValidator.validateGender,
          builder: (FormFieldState<String> field) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _GenderButton(
                        gender: '남성',
                        isSelected: field.value == '남성',
                        onTap: () {
                          field.didChange('남성');
                          onChanged('남성');
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _GenderButton(
                        gender: '여성',
                        isSelected: field.value == '여성',
                        onTap: () {
                          field.didChange('여성');
                          onChanged('여성');
                        },
                      ),
                    ),
                  ],
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}

class _GenderButton extends StatelessWidget {
  final String gender;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.gender,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
