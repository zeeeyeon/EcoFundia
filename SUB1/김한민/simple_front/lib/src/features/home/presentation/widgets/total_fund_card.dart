import 'package:flutter/material.dart';
import 'dart:math';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TotalFundCard extends StatefulWidget {
  final String amount;

  const TotalFundCard({
    super.key,
    required this.amount,
  });

  @override
  State<TotalFundCard> createState() => _TotalFundCardState();
}

class _TotalFundCardState extends State<TotalFundCard>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late String _displayAmount;

  @override
  void initState() {
    super.initState();
    _displayAmount = widget.amount;

    // 🔥 각 숫자가 개별적으로 회전하도록 애니메이션 컨트롤러 생성
    _controllers = List.generate(
      widget.amount.length,
      (index) => AnimationController(
        duration: Duration(
          milliseconds: 1500 + Random().nextInt(3000), // 1.5초 ~ 4.5초 랜덤 회전
        ),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic, // ✅ 초반엔 빠르게, 후반엔 서서히 멈추는 효과
      );
    }).toList();

    // 초기 애니메이션 시작
    _startAnimation();
  }

  @override
  void didUpdateWidget(TotalFundCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _displayAmount = widget.amount;
      _startAnimation();
    }
  }

  void _startAnimation() {
    for (var controller in _controllers) {
      controller.reset();
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white,
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildSpinningDigits(_displayAmount),
        ),
      ),
    );
  }

  /// 🔥 슬롯머신 효과를 위한 숫자 애니메이션
  List<Widget> _buildSpinningDigits(String amount) {
    return amount.split('').asMap().entries.map((entry) {
      int index = entry.key;
      String char = entry.value;

      if (char == ',') {
        return const Text(
          ',',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        );
      }

      return AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          double angle =
              (1 - _animations[index].value) * pi * 30; // ✅ 초반엔 30바퀴 회전
          return Transform(
            transform: Matrix4.rotationX(angle),
            alignment: Alignment.center,
            child: Opacity(
              opacity: _animations[index].value, // 점점 선명해지는 효과
              child: Text(
                char,
                key: ValueKey<String>(char),
                style: AppTextStyles.totalFund.copyWith(
                  color: AppColors.primary,
                  height: 1.1,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }
}
