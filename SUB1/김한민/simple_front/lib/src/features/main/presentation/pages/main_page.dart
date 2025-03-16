import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
      ),
      body: const Center(
        child: Text('메인 페이지'),
      ),
    );
  }
}
