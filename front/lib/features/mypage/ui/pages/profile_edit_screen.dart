import 'package:flutter/material.dart';
import 'package:front/features/mypage/ui/widgets/profile_edit_form.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: '프로필 수정',
        showBackButton: true,
      ),
      body: ProfileEditForm(),
    );
  }
}
