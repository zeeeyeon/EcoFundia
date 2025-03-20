import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';

class MyFundingScreen extends StatelessWidget {
  const MyFundingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: '내 펀딩',
      ),
      body: Center(
        child: Text("내가 참여한 펀딩 내역을 표시합니다."),
      ),
    );
  }
}
