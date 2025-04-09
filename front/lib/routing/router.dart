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
      final appFullState = ref.read(appStateProvider);
      final isLoggedIn = appFullState.isLoggedIn;
      final isInitialized = appFullState.isInitialized;
      final location = state.uri.toString();
      final targetPath = state.matchedLocation;

      LoggerUtil.d(
          '🔄 [Router Redirect] 현재 위치: $location (매칭: $targetPath), 로그인: $isLoggedIn, 초기화: $isInitialized');

      // 1. 초기화가 완료되지 않았으면 아무것도 하지 않음 (스플래시 또는 로딩 화면 유지)
      if (!isInitialized) {
        LoggerUtil.d('🔄 [Router Redirect] 초기화 진행 중 -> 대기');
        return null;
      }

      // 2. 초기화 완료 후 스플래시 화면에 있다면 상태에 따라 이동
      if (location == '/splash') {
        final target = isLoggedIn ? '/' : '/login';
        LoggerUtil.d('🚀 [Router Redirect] 초기화 완료 & 스플래시 -> $target 이동');
        return target;
      }

      // 3. 로그인/회원가입 관련 페이지 처리 (기존 로직 유지)
      final isAuthFlow = location == '/login' ||
          location == '/signup' ||
          location.startsWith('/signup-complete');

      if (isLoggedIn && isAuthFlow) {
        LoggerUtil.d('🏠 [Router Redirect] 로그인 상태 & 인증 페이지($location) -> / 이동');
        return '/';
      }

      if (!isLoggedIn && isAuthFlow) {
        LoggerUtil.d('🔄 [Router Redirect] 로그아웃 상태 & 인증 페이지($location) -> 통과');
        return null;
      }

      // 4. 로그인이 필요한 경로인지 확인 (state.uri.path 사용)
      final currentUriPath = state.uri.path; // 실제 접근 경로 사용
      final isAuthRequiredPath = requiresAuthPaths.any(
        (requiredPath) => currentUriPath.startsWith(requiredPath),
      );
      LoggerUtil.d(
          '🔒 [Router Redirect] 보호 경로 확인: $currentUriPath -> $isAuthRequiredPath');

      // 5. 로그아웃 상태 + 보호된 경로 접근 -> 로그인 페이지로 리디렉션
      if (!isLoggedIn && isAuthRequiredPath) {
        LoggerUtil.d(
            '🔒 [Router Redirect] 로그아웃 상태 & 보호된 경로($currentUriPath) -> /login 이동');
        return '/login';
      }

      // 6. 그 외 모든 경우 -> 허용 (기존 로직 유지)
      LoggerUtil.d('🔄 [Router Redirect] 리디렉션 필요 없음 ($location)');
      return null;
    },
    routes: [
      // 분리된 인증 및 공통 라우트 사용
      ...authRoutes,
      ...commonRoutes,

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
