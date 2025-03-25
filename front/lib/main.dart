import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/routing/router.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_view_model.dart';

void main() async {
  // Flutter 초기화 확인
  WidgetsFlutterBinding.ensureInitialized();

  // 로그 수준 설정
  LoggerUtil.setLogLevel(LogLevel.info); // info 레벨 이상만 출력

  // 스토리지 서비스 초기화
  await StorageService.init();

  final apiService = ApiService();

  runApp(
    ProviderScope(
      overrides: [
        apiServiceProvider.overrideWithValue(apiService),
        wishlistRepositoryProvider.overrideWith(
            (ref) => WishlistRepositoryImpl(apiService: apiService)),
      ],
      child: const MyApp(),
    ),
  );
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
