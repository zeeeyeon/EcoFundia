import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/wishlist/data/services/wishlist_api_service.dart';
import 'package:front/routing/router.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_provider.dart';
import 'package:front/shared/seller/data/repositories/seller_repository_impl.dart'
    as repo_impl;
import 'package:front/shared/seller/ui/view_model/seller_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:front/core/config/app_config.dart';

/// 앱 진입점
void main() async {
  // Flutter 초기화 확인
  WidgetsFlutterBinding.ensureInitialized();

  // 로그 수준 설정
  LoggerUtil.setLogLevel(LogLevel.info); // info 레벨 이상만 출력

  try {
    // Google Fonts 미리 로드 - 텍스트가 'x'로 깨지는 문제 해결
    await GoogleFonts.pendingFonts([
      GoogleFonts.roboto(),
      GoogleFonts.righteous(),
      GoogleFonts.urbanist(),
      GoogleFonts.spaceGrotesk(),
    ]);

    // 스토리지 서비스 초기화
    await StorageService.init();

    // 토큰 상태 주기적 확인 타이머 설정
    _setupTokenRefreshTimer();

    LoggerUtil.i('✅ 앱 초기화 완료');
  } catch (e) {
    LoggerUtil.e('❌ 앱 초기화 실패', e);
  }

  final apiService = ApiService();

  runApp(
    ProviderScope(
      overrides: [
        apiServiceProvider.overrideWithValue(apiService),
        wishlistRepositoryProvider.overrideWith((ref) => WishlistRepositoryImpl(
            wishlistService: WishlistApiService(apiService.dio))),
        // 판매자 Repository Provider 등록
        sellerRepositoryProvider
            .overrideWith((ref) => repo_impl.SellerRepositoryImpl(apiService)),
      ],
      child: const MyApp(),
    ),
  );
}

/// 토큰 갱신 타이머 설정
void _setupTokenRefreshTimer() {
  final interval = Duration(
    minutes: AppConfig.tokenConfig.checkExpirationIntervalMinutes,
  );

  Timer.periodic(interval, (timer) async {
    await StorageService.checkAndRefreshTokenIfNeeded();
  });

  LoggerUtil.i('⏱️ 토큰 상태 확인 타이머 설정됨: ${interval.inMinutes}분 간격');
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.mainColor,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
