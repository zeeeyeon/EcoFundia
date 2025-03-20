import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';

class MyReviewScreen extends StatelessWidget {
  const MyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: '내 리뷰',
      ),
      body: Center(
        child: Text("내가 작성한 후기 목록을 표시합니다."),
      ),
    );
  }
}
