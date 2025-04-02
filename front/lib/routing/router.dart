import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/funding/ui/pages/search_screen.dart';
import 'package:front/features/mypage/ui/pages/coupon_screen.dart';
import 'package:front/features/mypage/ui/pages/edit_review_screen.dart';
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
import 'package:front/features/wishlist/ui/view_model/wishlist_view_model.dart';
import 'package:front/features/auth/ui/pages/signup_complete_screen.dart';
import 'package:front/shared/seller/ui/pages/seller_detail_screen.dart';
import 'package:front/features/home/ui/pages/project_detail_screen.dart';
import 'package:front/shared/payment/ui/pages/payment_page.dart';
import 'package:front/shared/payment/ui/pages/payment_complete_page.dart';
import 'package:front/utils/auth_utils.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';
import 'package:front/features/funding/ui/view_model/funding_list_view_model.dart';
import 'package:front/features/home/ui/view_model/project_view_model.dart';
import 'package:front/features/mypage/ui/view_model/profile_view_model.dart';
import 'package:front/features/mypage/ui/view_model/total_funding_provider.dart';

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
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'funding_tab'),
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
                name: 'FundingDetail',
                pageBuilder: (context, state) {
                  final funding = state.extra as FundingModel;

                  return MaterialPage(
                    child: FundingDetailScreen(fundingId: funding.fundingId),
                  );
                },
              ),
              GoRoute(
                path: '/seller/:sellerId', // sellerId를 파라미터로 받음
                name: 'sellerDetail',
                builder: (context, state) {
                  final sellerId = int.parse(state.pathParameters['sellerId']!);
                  return SellerDetailScreen(sellerId: sellerId);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'home_tab'),
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
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'wishlist_tab'),
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
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'mypage_tab'),
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
                path: '/review/edit/:id',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  final extra = state.extra as Map<String, dynamic>?;

                  return EditReviewScreen(
                    reviewId: id,
                    initialRating: extra?['rating'] ?? 5,
                    initialContent: extra?['content'] ?? '',
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

class ScaffoldWithNavBar extends StatefulWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key);

  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  int _previousIndex = 0;

  // 각 탭 별 키 생성
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(debugLabel: 'funding'),
    GlobalKey<NavigatorState>(debugLabel: 'home'),
    GlobalKey<NavigatorState>(debugLabel: 'wishlist'),
    GlobalKey<NavigatorState>(debugLabel: 'mypage'),
  ];

  @override
  Widget build(BuildContext context) {
    // 현재 탭 인덱스 확인
    final currentIndex = widget.navigationShell.currentIndex;
    _previousIndex = currentIndex;

    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          key: ValueKey('main_scaffold_$currentIndex'),
          body: widget.navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              // 같은 탭을 다시 클릭한 경우
              if (index == currentIndex) {
                // 현재 탭의 페이지를 다시 로드
                widget.navigationShell.goBranch(
                  index,
                  initialLocation: true, // 초기 위치로 다시 이동
                );
              } else {
                // 다른 탭으로 이동
                widget.navigationShell.goBranch(index, initialLocation: true);
              }

              // ViewModel 리로드: 선택된 탭에 따라 데이터를 다시 불러옵니다
              // 이 부분을 탭 이동 후에 항상 실행하도록 변경
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final currentPath = GoRouterState.of(context).uri.path;

                switch (index) {
                  case 0: // 펀딩 탭
                    // 현재 경로가 펀딩 탭이면 데이터 로드
                    if (currentPath == '/funding') {
                      ref.read(fundingListProvider.notifier).fetchFundingList(
                            page: 1,
                            sort: ref.read(sortOptionProvider),
                            categories: ref.read(selectedCategoriesProvider),
                          );
                    }
                    break;
                  case 1: // 홈 탭
                    // 현재 경로가 홈 탭이면 데이터 로드
                    if (currentPath == '/') {
                      ref
                          .read(projectViewModelProvider.notifier)
                          .loadProjects();
                    }
                    break;
                  case 2: // 찜 탭
                    // 현재 경로가 찜 탭이면 데이터 로드
                    if (currentPath == '/wishlist') {
                      ref
                          .read(wishlistViewModelProvider.notifier)
                          .loadWishlistItems();
                    }
                    break;
                  case 3: // 마이페이지 탭
                    // 현재 경로가 마이페이지 탭이면 데이터 로드
                    if (currentPath == '/mypage') {
                      ref.refresh(profileProvider); // 마이페이지 프로필 정보 갱신
                      ref.refresh(totalFundingAmountProvider); // 펀딩 금액 정보 갱신
                    }
                    break;
                }
              });
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.store), label: '펀딩'),
              NavigationDestination(icon: Icon(Icons.home), label: '홈'),
              NavigationDestination(icon: Icon(Icons.favorite), label: '찜'),
              NavigationDestination(icon: Icon(Icons.person), label: '마이페이지'),
            ],
          ),
        );
      },
    );
  }
}
