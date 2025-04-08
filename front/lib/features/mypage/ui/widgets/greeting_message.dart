import 'package:flutter/material.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import '../../data/models/profile_model.dart';

class GreetingMessage extends StatelessWidget {
  final ProfileModel profile;

  const GreetingMessage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        AppTextStyles.body1.copyWith(fontSize: 16, color: AppColors.textDark);
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);
    final primaryStyle = baseStyle.copyWith(color: AppColors.primary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4.0,
          runSpacing: 4.0,
          children: [
            Text(profile.nickname, style: boldStyle),
            Text(MypageString.greetingmessage, style: primaryStyle),
            const Icon(Icons.spa_outlined, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}
