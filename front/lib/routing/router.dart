import 'dart:async';
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
import 'package:front/features/auth/ui/pages/signup_complete_screen.dart';
import 'package:front/shared/seller/ui/pages/seller_detail_screen.dart';
import 'package:front/features/home/ui/pages/project_detail_screen.dart';
import 'package:front/shared/payment/ui/pages/payment_page.dart';
import 'package:front/shared/payment/ui/pages/payment_complete_page.dart';
import 'package:front/utils/auth_utils.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/providers/app_state_provider.dart';

// 필요한 ViewModel Provider들을 import
import 'package:front/features/funding/ui/view_model/funding_list_view_model.dart';
import 'package:front/features/home/ui/view_model/project_view_model.dart';
import 'package:front/features/home/ui/view_model/home_view_model.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_view_model.dart';
import 'package:front/features/mypage/ui/view_model/profile_view_model.dart';
import 'package:front/features/mypage/ui/view_model/total_funding_provider.dart';

// 정적으로 선언된 GlobalKey - 싱글턴으로 관리
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
}

final routerProvider = Provider<GoRouter>((ref) {
  // 인증 상태 변경을 감지하는 ValueNotifier
  final authStateListenable = ValueNotifier<bool>(false); // 초기값 설정

  // isAuthenticatedProvider의 변경 감지
  ref.listen<AsyncValue<bool>>(isAuthenticatedProvider, (_, next) {
    // 상태가 로딩 중이 아니고 데이터가 있는 경우에만 업데이트
    if (!next.isLoading && next.hasValue) {
      authStateListenable.value = next.value!;
      LoggerUtil.d('🔑 인증 상태 변경 감지: ${next.value}');
    }
  });

  return GoRouter(
    navigatorKey: AppNavigatorKeys.instance.rootNavigatorKey, // 루트 네비게이터 키 추가
    initialLocation: '/splash', // ✅ 앱 실행 시 먼저 스플래시 화면 표시
    refreshListenable: authStateListenable, // ✅ 인증 상태 변경 감지 리스너 추가
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
          return ProjectDetailScreen(projectId: projectId);
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
          // navigationShell에 명시적 키 설정
          return ScaffoldWithNavBar(
            navigationShell: navigationShell,
            key: const ValueKey('scaffold_with_navbar'),
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: AppNavigatorKeys.instance.fundingTabKey, // ✅ 싱글턴 키 사용
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
            navigatorKey: AppNavigatorKeys.instance.homeTabKey, // ✅ 싱글턴 키 사용
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
            navigatorKey:
                AppNavigatorKeys.instance.wishlistTabKey, // ✅ 싱글턴 키 사용
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
            navigatorKey: AppNavigatorKeys.instance.mypageTabKey, // ✅ 싱글턴 키 사용
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
    this.shellKey,
    Key? key,
  }) : super(key: key);

  final StatefulNavigationShell navigationShell;
  final Key? shellKey; // 네비게이션 쉘에 전달할 키 추가

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  // Debounce를 위한 Timer 변수 추가
  Timer? _debounce;

  // 네비게이션 쉘 래핑을 위한 전역 키
  final _shellContainerKey = GlobalKey(debugLabel: 'shell_container_key');

  @override
  void dispose() {
    _debounce?.cancel(); // 위젯 dispose 시 타이머 취소
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 탭 인덱스 확인
    final currentIndex = widget.navigationShell.currentIndex;

    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          // 매번 새 키를 생성하지 않고 정적인 키 사용
          key: const ValueKey('main_scaffold'),
          // 네비게이션 쉘을 KeyedSubtree로 래핑하여 키 중복 문제 방지
          body: KeyedSubtree(
            key: _shellContainerKey,
            child: widget.navigationShell,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              // 디바운싱: 짧은 시간 내 중복 탭 방지
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 200), () {
                final previousIndex = currentIndex; // 이전 인덱스 저장

                // 다른 탭으로 이동하거나 같은 탭을 다시 눌렀을 때
                widget.navigationShell.goBranch(
                  index,
                  initialLocation: index == previousIndex, // 같은 탭이면 초기 위치로
                );

                // 선택된 탭에 따라 해당 ViewModel 데이터 새로고침
                _refreshTabData(ref, index);
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

  // 선택된 탭에 따라 데이터 새로고침
  void _refreshTabData(WidgetRef ref, int index) {
    try {
      // 인증 상태 확인 (isLoggedIn은 동기적으로 현재 상태 확인)
      final isLoggedIn = ref.read(appStateProvider).isLoggedIn;
      LoggerUtil.d('🔒 탭 $index 새로고침 - 인증 상태: $isLoggedIn');

      switch (index) {
        case 0: // 펀딩 탭 - 인증 불필요
          // FundingListViewModel의 첫 페이지를 다시 로드
          ref.read(fundingListProvider.notifier).fetchFundingList(
                page: 1, // 첫 페이지부터 다시 로드
                sort: ref.read(sortOptionProvider), // 현재 정렬 유지
                categories: ref.read(selectedCategoriesProvider), // 현재 카테고리 유지
              );
          break;

        case 1: // 홈 탭 - 인증 불필요
          ref.read(projectViewModelProvider.notifier).loadProjects();
          break;

        case 2: // 찜 탭 - 인증 필요
          if (isLoggedIn) {
            ref.read(wishlistViewModelProvider.notifier).loadWishlistItems();
          } else {
            // 로그인되지 않은 경우, 위시리스트 초기화 (빈 상태로)
            ref.read(wishlistViewModelProvider.notifier).resetState();
            LoggerUtil.d('⚠️ 인증되지 않음: 위시리스트 초기화');
          }
          break;

        case 3: // 마이페이지 탭 - 인증 필요
          if (isLoggedIn) {
            // 현재 Provider 상태에 따라 refresh 또는 invalidate 사용
            ref.invalidate(profileProvider); // Provider를 무효화하여 다음 접근 시 새로고침
            ref.invalidate(totalFundingAmountProvider); // 총 펀딩 금액 갱신
          } else {
            // 로그인되지 않은 경우에 대한 처리는 UI단에서 이미 처리됨
            LoggerUtil.d('⚠️ 인증되지 않음: 프로필 데이터 로드하지 않음');
          }
          break;
      }
      LoggerUtil.d('🔄 탭 $index 선택됨 - 관련 데이터 새로고침 요청');
    } catch (e) {
      LoggerUtil.e('탭 데이터 새로고침 오류', e);
    }
  }
}
