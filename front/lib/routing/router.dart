import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/providers/app_state_provider.dart';
import './widgets/scaffold_with_nested_navigation.dart';
import './routes/auth_routes.dart';
import './routes/common_routes.dart';
import './routes/funding_routes.dart';
import './routes/wishlist_routes.dart';
import './routes/home_routes.dart';
import './routes/chat_routes.dart';
import './routes/mypage_routes.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:front/features/splash/ui/pages/splash_screen.dart';

// 정적으로 선언된 GlobalKey - 싱글턴으로 관리 (클래스 정의 복원)
class AppNavigatorKeys {
  // 싱글턴 패턴 구현
  static final AppNavigatorKeys _instance = AppNavigatorKeys._();
  static AppNavigatorKeys get instance => _instance;
  AppNavigatorKeys._();

  // 루트 네비게이터 키
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  // 쉘 네비게이터 키
  final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  // 각 탭별 네비게이터 키
  final fundingTabKey = GlobalKey<NavigatorState>(debugLabel: 'funding_tab');
  final homeTabKey = GlobalKey<NavigatorState>(debugLabel: 'home_tab');
  final wishlistTabKey = GlobalKey<NavigatorState>(debugLabel: 'wishlist_tab');
  final mypageTabKey = GlobalKey<NavigatorState>(debugLabel: 'mypage_tab');
  final chatTabKey = GlobalKey<NavigatorState>(debugLabel: 'chat_tab');
}

final routerProvider = Provider<GoRouter>((ref) {
  // ValueNotifier 대신 직접 AppState 구독
  // final appState = ref.watch(appStateProvider); // This line is removed

  // 보호된 경로 목록 정의
  final requiresAuthPaths = [
    '/wishlist', '/chat', '/mypage', '/my-funding', '/review/',
    '/my-reviews', '/profile-edit', '/coupons', '/payment', '/cart',
    '/chat/room/', '/seller/' // seller 추가
    // 필요한 다른 보호된 경로 추가...
  ];

  return GoRouter(
    navigatorKey: AppNavigatorKeys.instance.rootNavigatorKey,
    initialLocation: '/splash', // 초기 위치는 스플래시
    // refreshListenable 제거
    routerNeglect: true,
    debugLogDiagnostics: kDebugMode, // 디버그 모드에서만 로그 활성화

    routes: [
      // Splash Screen Route
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      // ShellRoute for bottom navigation bar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // ScaffoldWithNestedNavigation 위젯 사용
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // 각 탭 브랜치 정의 (네비게이션 바 순서와 일치시킴)
          createFundingBranch(
              AppNavigatorKeys.instance.fundingTabKey), // Index 0: Funding
          createWishlistBranch(
              AppNavigatorKeys.instance.wishlistTabKey), // Index 1: Wishlist
          createHomeBranch(
              AppNavigatorKeys.instance.homeTabKey), // Index 2: Home
          createChatBranch(
              AppNavigatorKeys.instance.chatTabKey), // Index 3: Chat
          createMypageBranch(
              AppNavigatorKeys.instance.mypageTabKey), // Index 4: Mypage
        ],
      ),
      // Non-shell routes (common_routes.dart, auth_routes.dart 등 사용)
      ...commonRoutes,
      ...authRoutes, // 로그인, 회원가입 등
      // 다른 Non-Shell 라우트 추가
      // ...fundingDetailRoutes, // funding_routes.dart 에서 분리 필요
      // ...sellerRoutes, // seller_routes.dart 에서 분리 필요
    ],

    redirect: (BuildContext context, GoRouterState state) {
      final appState = ref.watch(appStateProvider);
      final location = state.uri.toString(); // 목표 경로

      // ⭐ 로그아웃 진행 중이면 리디렉션 로직을 건너뛰기
      if (appState.isLoggingOut) {
        LoggerUtil.d('[Redirect] isLoggingOut = true -> Allow Navigation');
        return null;
      }

      final splash = location == '/splash';
      final loggingIn = location == '/login';
      final signingUp = location == '/signup';
      final signupComplete = location == '/signup-complete';

      final goingToAuthPage = loggingIn || signingUp || signupComplete;
      final goingToProtectedRoute =
          requiresAuthPaths.any((p) => location.startsWith(p));

      LoggerUtil.i(
          '[Router Redirect] Target: "$location", isLoggedIn: ${appState.isLoggedIn}, isInitialized: ${appState.isInitialized}');

      // 1. 초기화 전 처리
      if (!appState.isInitialized) {
        LoggerUtil.d(
            '[Redirect] Cond 1: Not Initialized -> ${splash ? "Allow Splash" : "Redirect to /splash"}');
        // 스플래시 화면으로 가는 것이 아니면 스플래시로 리디렉션
        return splash ? null : '/splash';
      }

      // --- 초기화 완료 ---
      final isLoggedIn = appState.isLoggedIn;

      // 2. 로그인 상태일 때
      if (isLoggedIn) {
        if (splash) {
          // 초기화 후 스플래시에 있다면 홈으로
          LoggerUtil.d('[Redirect] Cond 2.1: LoggedIn & Target Splash -> /');
          return '/';
        }
        if (goingToAuthPage) {
          // 로그인/회원가입 페이지로 가려고 하면 홈으로
          LoggerUtil.d('[Redirect] Cond 2.2: LoggedIn & Target Auth -> /');
          return '/';
        }
        // 그 외 모든 페이지 접근 허용
        LoggerUtil.d('[Redirect] Cond 2.3: LoggedIn & Target Other -> Allow');
        return null;
      }
      // 3. 로그아웃 상태일 때
      else {
        // ⭐ 수정: 초기화 완료 후 스플래시에 있다면 무조건 홈으로 이동
        if (splash) {
          LoggerUtil.d(
              '[Redirect] Cond 3.1: Initialized & LoggedOut & Target Splash -> /');
          return '/'; // 홈으로 리디렉션
        }
        // 로그인/회원가입 관련 페이지는 접근 허용
        if (goingToAuthPage) {
          LoggerUtil.d('[Redirect] Cond 3.2: LoggedOut & Target Auth -> Allow');
          return null;
        }
        // 보호된 경로로 가려고 하면 로그인 페이지로 리디렉션
        if (goingToProtectedRoute) {
          LoggerUtil.d(
              '[Redirect] Cond 3.3: LoggedOut & Target Protected -> /login');
          return '/login';
        }
        // 그 외 모든 페이지 접근 허용 (예: 홈 '/')
        LoggerUtil.d(
            '[Redirect] Cond 3.4: LoggedOut & Target Non-Protected/Non-Auth -> Allow');
        return null;
      }
    },
    onException: (context, state, router) {
      LoggerUtil.e('[GoRouter] 라우팅 예외 처리: ${state.uri}, 오류: ${state.error}');
      try {
        // 오류 표시 (선택적)
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('페이지를 찾을 수 없거나 오류가 발생했습니다: ${state.error}'),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // 오류 발생 시 안전하게 홈으로 리디렉션
        Future.delayed(const Duration(milliseconds: 300), () {
          router.go('/');
        });
      } catch (e) {
        LoggerUtil.e('[GoRouter] 예외 처리 중 추가 오류: $e');
      }
    },
    // errorBuilder 제거
  );
});

// ScaffoldWithNavBar 위젯 - scaffold_with_nested_navigation.dart로 이동됨
// class ScaffoldWithNavBar extends ConsumerStatefulWidget { ... }
// class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> { ... }

// GoRouterRefreshStream 클래스 (기존 정의 유지)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
