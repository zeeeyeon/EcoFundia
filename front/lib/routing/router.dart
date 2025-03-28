import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/funding/ui/pages/search_screen.dart';
import 'package:front/features/mypage/ui/pages/coupon_screen.dart';
import 'package:front/features/mypage/ui/pages/my_review_screen.dart';
import 'package:front/features/mypage/ui/pages/profile_edit_screen.dart';
import 'package:front/features/mypage/ui/pages/support/faq_screen.dart';
import 'package:front/features/mypage/ui/pages/support/guide_screen.dart';
import 'package:front/features/mypage/ui/pages/support/notice_screen.dart';
import 'package:front/features/mypage/ui/pages/support/policy_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/auth/ui/pages/login_screen.dart';
import 'package:front/features/auth/ui/pages/sign_up_screen.dart';
import 'package:front/features/splash/ui/pages/splash_screen.dart';
import 'package:front/features/funding/data/models/funding_model.dart';
import 'package:front/features/funding/ui/pages/funding_list_screen.dart';
import 'package:front/features/funding/ui/pages/funding_detail_screen.dart';
import 'package:front/features/home/ui/pages/home_screen.dart';
import 'package:front/features/mypage/ui/pages/mypage_screen.dart';
import 'package:front/features/mypage/ui/pages/my_funding_screen.dart';
import 'package:front/features/mypage/ui/pages/write_review_screen.dart';
import 'package:front/features/wishlist/ui/pages/wishlist_screen.dart';
import 'package:front/features/auth/ui/pages/signup_complete_screen.dart';
import 'package:front/shared/seller/ui/pages/seller_detail_screen.dart';
import 'package:front/features/home/ui/pages/project_detail_screen.dart';
import 'package:front/shared/payment/ui/pages/payment_page.dart';
import 'package:front/shared/payment/ui/pages/payment_complete_page.dart';
import 'package:front/utils/auth_utils.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash', // ✅ 앱 실행 시 먼저 스플래시 화면 표시
    redirect: (context, state) async {
      //권한체크
      return await AuthUtils.checkAuthForRoute(context, ref, state);
    },
    routes: [
      // 인증 관련 라우트
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
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
        path: '/signup-complete',
        name: 'signup-complete',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return SignupCompleteScreen(nickname: extras?['nickname'] ?? '');
        },
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      // 프로젝트 상세 페이지
      GoRoute(
        path: '/project/:id',
        builder: (context, state) {
          final projectId = int.parse(state.pathParameters['id'] ?? '1');
          final project = (state.extra as Map<String, dynamic>?)?['project']
              as ProjectEntity?;
          return ProjectDetailScreen(projectId: projectId, project: project);
        },
      ),
      // 판매자 상세 페이지
      GoRoute(
        path: '/seller/:id',
        builder: (context, state) {
          final sellerId = int.parse(state.pathParameters['id'] ?? '1');
          return SellerDetailScreen(sellerId: sellerId);
        },
      ),
      // 결제 완료 페이지
      GoRoute(
        path: '/payment/complete',
        name: 'payment-complete',
        builder: (context, state) {
          return const PaymentCompletePage();
        },
      ),
      // 결제 페이지
      GoRoute(
        path: '/payment/:productId',
        name: 'payment',
        builder: (context, state) {
          final productId = state.pathParameters['productId'] ?? '';
          return PaymentPage(productId: productId);
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
                builder: (context, state) => const FundingListScreen(),
              ),
              GoRoute(
                path: '/funding/search',
                builder: (context, state) =>
                    const SearchScreen(), // 🔍 검색 화면 추가
              ),
              GoRoute(
                path: '/funding/detail',
                builder: (context, state) {
                  final funding = state.extra as FundingModel;
                  return FundingDetailScreen(funding: funding);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    key: ValueKey('home'),
                    child: HomeScreen(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wishlist',
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    key: ValueKey('wishlist'),
                    child: WishlistScreen(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mypage',
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    key: ValueKey('mypage'),
                    child: MypageScreen(),
                  );
                },
              ),
              GoRoute(
                path: '/my-funding',
                builder: (context, state) => const MyFundingScreen(),
              ),
              GoRoute(
                path: '/review/:id',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  final extra = state.extra as Map<String, dynamic>?;

                  return WriteReviewScreen(
                    fundingId: id,
                    title: extra?['title'] ?? '',
                    description: extra?['description'] ?? '',
                    totalPrice: extra?['totalPrice'] ?? 0,
                  );
                },
              ),
              GoRoute(
                path: '/my-reviews',
                name: 'myReviews',
                builder: (context, state) => const MyReviewScreen(),
              ),
              GoRoute(
                path: '/profile-edit',
                builder: (context, state) => const ProfileEditScreen(),
              ),
              GoRoute(
                path: '/coupons',
                builder: (context, state) => const CouponScreen(),
              ),
              GoRoute(
                path: '/support/faq',
                builder: (context, state) => const FaqScreen(),
              ),
              GoRoute(
                path: '/support/notice',
                builder: (context, state) => const NoticeScreen(),
              ),
              GoRoute(
                path: '/support/guide',
                builder: (context, state) => const GuideScreen(),
              ),
              GoRoute(
                path: '/support/policy',
                builder: (context, state) => const PolicyScreen(),
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
