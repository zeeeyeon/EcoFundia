import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/auth/ui/pages/login_screen.dart';
import 'package:front/features/auth/ui/pages/sign_up_screen.dart';
import 'package:front/features/auth/ui/view_model/auth_provider.dart';
import 'package:front/features/splash/ui/pages/splash_screen.dart';
import 'package:front/features/funding/ui/pages/funding_screen.dart';
import 'package:front/features/home/ui/pages/home_screen.dart';
import 'package:front/features/mypage/ui/pages/mypage_screen.dart';
import 'package:front/features/wishlist/ui/pages/wishlist_screen.dart';
import 'package:front/features/auth/ui/pages/signup_complete_screen.dart';

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
        path: '/signup',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          final name = extras?['name'] as String?;
          final email = extras?['email'] as String? ?? '';
          final token = extras?['token'] as String?;

          return SignUpScreen(
            name: name,
            email: email,
            token: token,
          );
        },
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup-success',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          final nickname = extras?['nickname'] as String?;
          return SignupCompleteScreen(nickname: nickname ?? '');
        },
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
                builder: (context, state) => const FundingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wishlist',
                builder: (context, state) => const WishlistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mypage',
                builder: (context, state) => const MypageScreen(),
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
