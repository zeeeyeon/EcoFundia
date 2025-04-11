import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/utils/logger_util.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  double _firstTextOpacity = 0.0; // 첫 번째 텍스트 초기 투명도
  double _secondTextOpacity = 0.0; // 두 번째 텍스트 초기 투명도
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();

    // 1️⃣ 0.5초 후 첫 번째 텍스트 서서히 등장 (페이드 인)
    _timers.add(Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _firstTextOpacity = 1.0;
      });
    }));

    // 2️⃣ 2초 후 첫 번째 텍스트 서서히 사라짐 (페이드 아웃)
    _timers.add(Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _firstTextOpacity = 0.0;
      });
    }));

    // 3️⃣ 첫 번째 텍스트가 사라진 후, 두 번째 텍스트 등장
    _timers.add(Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _secondTextOpacity = 1.0;
      });
    }));

    // 4️⃣ 전체 애니메이션 완료 후 앱 초기화 완료 설정 및 홈 화면으로 이동
    _timers.add(Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      LoggerUtil.i('✅ 스플래시 애니메이션 완료, 앱 초기화 설정');

      // 인증 상태 확인
      ref.read(isAuthenticatedProvider.future).then((isLoggedIn) {
        // 앱 초기화 상태 설정 - 이것이 라우터의 redirect 로직을 트리거함
        ref.read(appStateProvider.notifier).setInitialized(true);
        LoggerUtil.i('🚀 앱 초기화 완료, 홈 화면으로 이동 (로그인 상태: $isLoggedIn)');
      });
    }));
  }

  @override
  void dispose() {
    // 모든 타이머 취소
    for (var timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height: screenSize.width * 0.25, // ✅ 두 텍스트의 위치를 유지하기 위한 공간
          child: Stack(
            alignment: const Alignment(0, -0.2),
            children: [
              /// 🔥 첫 번째 텍스트 (서서히 나타났다 → 사라짐)
              AnimatedOpacity(
                duration: const Duration(seconds: 1),
                opacity: _firstTextOpacity,
                child: Text(
                  '당신의 상상을 펀딩하다.',
                  style: SplashTextStyles.text.copyWith(
                    fontSize: screenSize.width * 0.08,
                    color: AppColors.primary,
                  ),
                ),
              ),

              /// 🔥 두 번째 텍스트 (첫 번째 텍스트가 사라진 후 동일한 위치에서 나타남)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500), // ✅ 빠르게 등장
                opacity: _secondTextOpacity,
                child: Text(
                  'Eco Fundia',
                  style: SplashTextStyles.text.copyWith(
                    fontSize: screenSize.width * 0.12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
