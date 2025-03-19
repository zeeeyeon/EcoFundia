import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:front/core/ui/widgets/custom_button.dart';
import 'package:go_router/go_router.dart';

class SignupCompleteScreen extends StatefulWidget {
  const SignupCompleteScreen({Key? key}) : super(key: key);

  @override
  State<SignupCompleteScreen> createState() => _SignupCompleteScreenState();
}

class _SignupCompleteScreenState extends State<SignupCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              // Lottie 애니메이션 추가 - 초록색 계열로 변경
              Lottie.network(
                'https://assets5.lottiefiles.com/packages/lf20_touohxv0.json', // 초록색 체크 애니메이션
                controller: _controller,
                height: 200,
                repeat: false,
              ),
              const SizedBox(height: 40),
              const Text(
                'SIMPLE 환영합니다!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E232C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                '누구나 만들 수 있어요.\n지금 시작해보세요.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8391A1),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CustomButton(
                text: '시작하기',
                backgroundColor: const Color(0xFFA3D80D),
                onPressed: () => context.go('/'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
