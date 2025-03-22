import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/auth/ui/pages/login_screen.dart';
import 'package:front/features/auth/ui/pages/sign_up_screen.dart';
import 'package:front/features/splash/ui/pages/splash_screen.dart';
import 'package:front/features/funding/ui/pages/funding_screen.dart';
import 'package:front/features/home/ui/pages/home_screen.dart';
import 'package:front/features/mypage/ui/pages/mypage_screen.dart';
import 'package:front/features/wishlist/ui/pages/wishlist_screen.dart';
import 'package:front/features/auth/ui/pages/signup_complete_screen.dart';
import 'package:front/shared/seller/ui/pages/seller_detail_screen.dart';
import 'package:front/utils/auth_utils.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      // AuthUtils를 통해 권한 체크
      return await AuthUtils.checkAuthForRoute(
        context,
        ref,
        state,
      );
    },
    routes: [
      // 인증 관련 라우트
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return SignUpScreen(
            name: extras?['name'],
            email: extras?['email'] ?? '',
            token: extras?['token'],
          );
        },
      ),
      GoRoute(
        path: '/signup-success',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return SignupCompleteScreen(nickname: extras?['nickname'] ?? '');
        },
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      // 판매자 상세 페이지
      GoRoute(
        path: '/seller/:id',
        builder: (context, state) {
          final sellerId = int.parse(state.pathParameters['id'] ?? '1');
          return SellerDetailScreen(sellerId: sellerId);
        },
      ),
      // 메인 네비게이션
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
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index);
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
