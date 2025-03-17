import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_front/src/features/auth/presentation/pages/login_page.dart';
import 'package:simple_front/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:simple_front/src/features/funding/presentation/pages/funding_page.dart';
import 'package:simple_front/src/features/home/presentation/pages/home_page.dart';
import 'package:simple_front/src/features/mypage/presentation/pages/mypage_page.dart';
import 'package:simple_front/src/features/splash/presentation/pages/splash_page.dart';
import 'package:simple_front/src/features/wishlist/presentation/pages/wishlist_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash', // ✅ 앱 실행 시 먼저 스플래시 화면 표시
    redirect: (context, state) {
      final isAuthenticated = ref.read(isLoggedInProvider);

      // 로그인 필수 페이지 처리 (마이페이지 & 찜 목록)
      if (!isAuthenticated &&
          (state.matchedLocation == '/mypage' ||
              state.matchedLocation == '/wishlist')) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      // SignUpPage는 필수 파라미터가 있어서 로그인 후 인증정보와 함께 이동해야 합니다.
      // 따라서 라우트에서 직접 등록하지 않고, 인증 후 context.go로 이동합니다.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/funding',
                builder: (context, state) => const FundingPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wishlist',
                builder: (context, state) => const WishlistPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mypage',
                builder: (context, state) => const MyPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key);

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex, // ✅ 선택된 탭 유지
        onDestinationSelected: (index) {
          navigationShell.goBranch(index); // ✅ 올바른 페이지 이동
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.store),
            label: '펀딩',
          ),
          NavigationDestination(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: '찜',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}
