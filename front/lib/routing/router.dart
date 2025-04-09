import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/ui/page/coming_soon_screen.dart';
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
import 'package:front/features/chat/ui/pages/chat_room_screen.dart';

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
  final appStateListenable =
      ValueNotifier<AppState>(ref.read(appStateProvider));

  // AppState 변경 감지 리스너 설정
  ref.listen<AppState>(appStateProvider, (_, nextState) {
    appStateListenable.value = nextState;
    LoggerUtil.d(
        '🔄 [Router Listen] AppState 변경 감지: isLoggedIn=${nextState.isLoggedIn}, isInitialized=${nextState.isInitialized}');
  });

  // 로그인이 필요한 경로 시작 부분 목록
  final requiresAuthPaths = [
    '/wishlist',
    '/chat',
    '/mypage', // /mypage 자체 포함
    '/my-funding',
    '/review/', // /review/:id, /review/edit/:id 포함
    '/my-reviews',
    '/profile-edit',
    '/coupons',
    '/payment', // /payment/:productId, /payment/complete 포함
    '/cart', // 예시 카트 경로 포함
    // 필요시 추가 경로
  ];

  return GoRouter(
    navigatorKey: AppNavigatorKeys.instance.rootNavigatorKey,
    initialLocation: '/splash', // 초기 위치는 스플래시
    refreshListenable: appStateListenable,
    redirect: (context, state) {
      final appState = ref.read(appStateProvider);
      final location = state.uri.toString();
      final currentUriPath = state.uri.path;

      LoggerUtil.i(
          '[Router Redirect START] Location: "$location", Path: "$currentUriPath", isLoggedIn: ${appState.isLoggedIn}, isInitialized: ${appState.isInitialized}');

      // --- 0. 인증 플로우 예외 처리 (로그아웃 상태에서만 유효) ---
      final isAuthProcessPath = currentUriPath == '/login' ||
          currentUriPath == '/signup' ||
          currentUriPath == '/signup-complete' ||
          currentUriPath == '/forgot-password';

      if (!appState.isLoggedIn && isAuthProcessPath) {
        // 회원가입 완료 후에는 로그인 상태여야 하므로, 로그아웃 상태 접근 시 로그인으로 보낼 수 있음
        if (currentUriPath == '/signup-complete') {
          LoggerUtil.w(
              '[Router Redirect] Cond 0.1: Logged out & Signup Complete -> Redirecting to /login');
          return '/login';
        }
        LoggerUtil.d(
            '[Router Redirect] Cond 0.2: Auth process page ($currentUriPath) & Logged out -> ALLOW');
        return null; // /login, /signup 등은 로그아웃 상태에서 접근 허용
      }

      // --- 1. 초기화 안 됐으면 스플래시 유지 또는 이동 ---
      if (!appState.isInitialized) {
        if (currentUriPath != '/splash') {
          LoggerUtil.d(
              '[Router Redirect] Cond 1.1: Not initialized & Not Splash -> Redirecting to /splash');
          return '/splash';
        }
        LoggerUtil.d(
            '[Router Redirect] Cond 1.2: Not initialized & Splash -> Stay on /splash');
        return null; // 스플래시 유지
      }

      // --- 2. 초기화 완료 & 스플래시 상태면 무조건 홈으로 이동 ---
      // 이 시점에는 isInitialized == true
      if (currentUriPath == '/splash') {
        // 로그인 여부와 관계없이 홈으로 보냄 (요구사항 반영)
        LoggerUtil.d(
            '[Router Redirect] Cond 2: Initialized & Splash -> Redirecting to "/"');
        return '/';
      }

      // --- 4. 로그아웃 상태 & 보호된 경로 접근 시 로그인으로 ---
      // 이 시점에는 isInitialized == true
      final isAuthRequired =
          requiresAuthPaths.any((p) => currentUriPath.startsWith(p)) ||
              currentUriPath.startsWith('/chat/room/');
      if (!appState.isLoggedIn && isAuthRequired) {
        LoggerUtil.d(
            '[Router Redirect] Cond 4: Logged out & Protected page ($currentUriPath) -> Redirecting to "/login"');
        return '/login'; // 로그인 페이지로 리디렉션
      }

      // --- 5. 그 외 모든 경우 (리디렉션 불필요) ---
      LoggerUtil.i(
          '[Router Redirect END] No redirection needed for path "$currentUriPath". Returning null.');
      return null; // 현재 경로 유지
    },
    routes: [
      // 분리된 인증 및 공통 라우트 사용
      ...authRoutes,
      ...commonRoutes,

      // Add Chat Room Route here, before the ShellRoute
      GoRoute(
        path: '/chat/room/:fundingId',
        name: 'chatRoom', // Keep the name if used elsewhere
        // No parentNavigatorKey needed, defaults to root
        builder: (context, state) {
          final fundingId =
              int.tryParse(state.pathParameters['fundingId'] ?? '');
          final extra = state.extra as Map<String, dynamic>?;

          if (fundingId == null) {
            LoggerUtil.e('Chat Room Route Error: Invalid or missing fundingId');
            return const ComingSoonScreen(); // Placeholder
          }

          return ChatRoomScreen(
            fundingId: fundingId,
            fundingTitle: extra?['title'] ?? '펀딩', // Use null-aware access
          );
        },
      ),

      // 메인 네비게이션 쉘 라우트
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(
            navigationShell: navigationShell,
            key: const ValueKey('scaffold_with_navbar'),
          );
        },
        branches: [
          // 분리된 브랜치 생성 함수 호출 (navigatorKey 전달)
          createFundingBranch(AppNavigatorKeys.instance.fundingTabKey),
          createWishlistBranch(AppNavigatorKeys.instance.wishlistTabKey),
          createHomeBranch(AppNavigatorKeys.instance.homeTabKey),
          createChatBranch(AppNavigatorKeys.instance.chatTabKey),
          createMypageBranch(AppNavigatorKeys.instance.mypageTabKey),
        ],
      ),
      // Coming Soon Page (Fallback)
      GoRoute(
        path: '/coming-soon',
        builder: (context, state) => const ComingSoonScreen(),
      ),
    ],
    // 에러 빌더 추가 (Fallback UI)
    errorBuilder: (context, state) {
      LoggerUtil.e(
          '[GoRouter Error] Path: ${state.uri}, Exception: ${state.error}');
      // ComingSoonScreen 대신 간단한 Text 위젯으로 에러 표시
      return Scaffold(
        appBar: AppBar(title: const Text('오류')),
        body: Center(
          child: Text('페이지를 찾을 수 없거나 오류가 발생했습니다.\n오류: ${state.error}'),
        ),
      );
    },
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
