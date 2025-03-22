import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';

class CouponScreen extends StatelessWidget {
  const CouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: '내 쿠폰',
        showBackButton: true,
      ),
      body: Center(
        child: Text(
          '보유한 쿠폰 목록을 표시합니다.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
