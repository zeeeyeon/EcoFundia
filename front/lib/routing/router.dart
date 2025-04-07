import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/chat/ui/pages/chat_room_screen.dart';
import 'package:front/features/chat/ui/pages/chat_screen.dart';
import 'package:front/features/funding/ui/pages/search_screen.dart';
import 'package:front/features/mypage/ui/pages/coupons_screen.dart';
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
import 'package:front/features/wishlist/ui/view_model/wishlist_view_model.dart';
import 'package:front/features/mypage/ui/view_model/profile_view_model.dart';
import 'package:front/features/mypage/ui/view_model/total_funding_provider.dart';
import 'package:front/features/mypage/ui/view_model/my_funding_view_model.dart';
import 'package:front/features/mypage/ui/view_model/my_review_view_model.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_provider.dart';
import 'package:front/features/mypage/ui/view_model/coupon_view_model.dart';

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
  final chatTabKey = GlobalKey<NavigatorState>(debugLabel: 'chat_tab');
}

// 각 탭별 마지막 데이터 로드 시간 추적
class TabLoadState {
  DateTime? lastHomeLoadTime;
  DateTime? lastFundingLoadTime;
  DateTime? lastWishlistLoadTime;
  DateTime? lastMypageLoadTime;
  DateTime? lastChatLoadTime;
  int lastTabIndex = 0; // 마지막으로 선택된 탭 인덱스

  // 각 탭별 상태 초기화 (앱 시작 또는 로그아웃 시 사용)
  void reset() {
    lastHomeLoadTime = null;
    lastFundingLoadTime = null;
    lastWishlistLoadTime = null;
    lastMypageLoadTime = null;
    lastChatLoadTime = null;
    lastTabIndex = 0;
  }
}

// 전역 상태 인스턴스
final _tabLoadState = TabLoadState();

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
    navigatorKey: AppNavigatorKeys.instance.rootNavigatorKey, // 싱글턴 인스턴스의 키 사용
    initialLocation: '/splash', // ✅ 앱 실행 시 먼저 스플래시 화면 표시
    refreshListenable: authStateListenable, // ✅ 인증 상태 변경 감지 리스너 추가
    redirect: (context, state) async {
      // 현재 경로가 로그인/스플래시 페이지인 경우 리디렉션 로직 건너뜀
      if (state.uri.toString() == '/login' ||
          state.uri.toString() == '/splash') {
        return null;
      }

      // 인증이 필요한 경로인지 확인
      final currentPath = state.uri.toString();
      if (AuthUtils.isAuthRequiredPath(currentPath)) {
        // 로그인 상태 확인
        final isLoggedIn = ref.read(isLoggedInProvider);

        if (!isLoggedIn) {
          LoggerUtil.d('🔒 라우트 권한 체크: 인증 필요 ($currentPath) → 로그인 페이지로 리다이렉션');
          return '/login';
        }
      }

      // 기존 체크 로직도 유지
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
            navigatorKey: AppNavigatorKeys.instance.mypageTabKey, // ✅ 싱글턴 키 사용
            routes: [
              GoRoute(
                path: '/chat',
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    key: ValueKey('chat'),
                    child: ChatScreen(),
                  );
                },
              ),
              GoRoute(
                path: '/chat/room/:fundingId',
                name: 'chatRoom',
                builder: (context, state) {
                  final fundingId =
                      int.parse(state.pathParameters['fundingId']!);
                  final extra = state.extra as Map<String, dynamic>?;

                  return ChatRoomScreen(
                    fundingId: fundingId,
                    fundingTitle: extra?['title'] ?? '펀딩',
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
                builder: (context, state) => const CouponsScreen(),
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

  // 탭별 마지막 데이터 로드 시간 추적
  final Map<int, DateTime> _lastTabRefreshTimes = {};
  // 이전에 선택된 탭 인덱스
  int _lastSelectedIndex = -1;

  // 탭 데이터 새로고침 사이의 최소 시간 간격 (초)
  static const int _minRefreshIntervalSeconds = 30;

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
                _refreshTabData(ref, index, previousIndex);
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.store),
                label: '펀딩',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite),
                label: '찜',
              ),
              NavigationDestination(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat),
                label: '채팅',
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                label: '마이페이지',
              ),
            ],
          ),
        );
      },
    );
  }

  // 선택된 탭에 따라 데이터 새로고침 - 통합 버전
  void _refreshTabData(WidgetRef ref, int index, int previousIndex) {
    try {
      // 인증 상태 확인 (isLoggedIn은 동기적으로 현재 상태 확인)
      final appState = ref.read(appStateProvider);
      final isLoggedIn = appState.isLoggedIn;

      // 현재 시간
      final now = DateTime.now();

      // 같은 탭을 클릭했는지 여부
      final isSameTab = index == previousIndex;

      // 마이페이지 또는 채팅/찜 탭이면서 로그인이 안 된 경우
      // 기본 탭으로 이동시키는 로직 추가 (옵션)
      if (!isLoggedIn && (index == 1 || index == 3 || index == 4)) {
        LoggerUtil.d('⚠️ 인증 필요 탭 접근 시도(탭 $index) - 로그인 필요');

        // 마이페이지의 경우 탭 자체를 변경하지 않고 로그인 요청 화면을 표시
        if (index == 4) {
          LoggerUtil.d('🔒 마이페이지 탭: 비로그인 상태로 접근 허용 (안내 화면 표시)');
          // 마이페이지 내부에서 로그인 안내 화면을 표시하므로 여기서는 별도 처리 없음
        }
      }

      // 마지막 로드 시간 확인 - 전역 시간 객체 또는 로컬 시간 객체
      DateTime? lastRefreshTime;

      // 탭 인덱스별 마지막 데이터 로드 시간 가져오기
      switch (index) {
        case 0: // 펀딩 탭
          lastRefreshTime = _tabLoadState.lastFundingLoadTime;
          break;
        case 1: // 위시리스트 탭
          lastRefreshTime = _tabLoadState.lastWishlistLoadTime;
          break;
        case 2: // 홈 탭
          lastRefreshTime = _tabLoadState.lastHomeLoadTime;
          break;
        case 3: // 채팅 탭
          lastRefreshTime = _tabLoadState.lastChatLoadTime;
          break;
        case 4: // 마이페이지 탭
          lastRefreshTime = _tabLoadState.lastMypageLoadTime;
          break;
      }

      // 같은 탭 클릭 시 항상 새로고침하거나, 다른 탭에서 돌아왔을 때 시간 기준 확인
      final isRefreshNeeded = isSameTab ||
          lastRefreshTime == null ||
          now.difference(lastRefreshTime).inSeconds >
              _minRefreshIntervalSeconds;

      LoggerUtil.d(
          '🔒 탭 $index 선택됨 - 이전 탭: $previousIndex, 마지막 선택 탭: $_lastSelectedIndex');
      LoggerUtil.d(
          '🔒 탭 $index 새로고침 조건 - 재로드 필요: $isRefreshNeeded, 인증 상태: $isLoggedIn, 같은 탭 클릭: $isSameTab');

      // 현재 탭 인덱스 저장
      _lastSelectedIndex = index;

      // 탭 데이터 로드가 필요한 경우에만 처리
      if (isRefreshNeeded) {
        switch (index) {
          case 0: // 펀딩 탭 - 인증 불필요
            // FundingListViewModel의 첫 페이지를 다시 로드
            LoggerUtil.i(
                '🔄 펀딩 탭 데이터 새로고침 ${isSameTab ? "(탭 재클릭)" : "(탭 전환)"}');

            try {
              // 첫 페이지부터 다시 로드
              ref.read(fundingListProvider.notifier).fetchFundingList(
                    page: 1, // 첫 페이지부터 다시 로드
                    sort: ref.read(sortOptionProvider), // 현재 정렬 유지
                    categories:
                        ref.read(selectedCategoriesProvider), // 현재 카테고리 유지
                  );
            } catch (e) {
              LoggerUtil.e('❌ 펀딩 목록 탭 데이터 로드 오류: $e');
            }

            // 위시리스트 ID 로드 (로그인 된 경우에만)
            if (isLoggedIn) {
              final loadWishlistIds = ref.read(loadWishlistIdsProvider);
              loadWishlistIds();
            }

            // 시간 업데이트
            _tabLoadState.lastFundingLoadTime = now;
            _lastTabRefreshTimes[index] = now;
            break;

          case 1: // 찜 탭 - 인증 필요
            if (isLoggedIn) {
              LoggerUtil.i(
                  '🔄 찜 탭 데이터 새로고침 ${isSameTab ? "(탭 재클릭)" : "(탭 전환)"}');

              // 위시리스트 데이터 로드
              ref.read(wishlistViewModelProvider.notifier).loadWishlistItems();

              // 위시리스트 ID 로드
              final loadWishlistIds = ref.read(loadWishlistIdsProvider);
              loadWishlistIds();

              // 시간 업데이트
              _tabLoadState.lastWishlistLoadTime = now;
              _lastTabRefreshTimes[index] = now;
            } else {
              // 로그인되지 않은 경우, 위시리스트 상태를 명시적으로 초기화
              ref.read(wishlistViewModelProvider.notifier).resetState();
              LoggerUtil.d('⚠️ 인증되지 않음: 위시리스트 초기화 완료');
            }
            break;

          case 2: // 홈 탭 - 인증 불필요
            LoggerUtil.i('🔄 홈 탭 데이터 새로고침 ${isSameTab ? "(탭 재클릭)" : "(탭 전환)"}');

            // 프로젝트 데이터 로드
            ref.read(projectViewModelProvider.notifier).loadProjects();

            // 위시리스트 ID 로드 (로그인 된 경우에만)
            if (isLoggedIn) {
              final loadWishlistIds = ref.read(loadWishlistIdsProvider);
              loadWishlistIds();
            }

            // 시간 업데이트
            _tabLoadState.lastHomeLoadTime = now;
            _lastTabRefreshTimes[index] = now;
            break;

          case 3: // 채팅 탭 - 인증 필요
            if (isLoggedIn) {
              LoggerUtil.i(
                  '🔄 채팅 탭 데이터 새로고침 ${isSameTab ? "(탭 재클릭)" : "(탭 전환)"}');

              // 채팅 데이터 로드 (향후 구현 예정)
              // TODO: 채팅 데이터 로드 구현

              // 시간 업데이트
              _tabLoadState.lastChatLoadTime = now;
              _lastTabRefreshTimes[index] = now;
            } else {
              LoggerUtil.d('⚠️ 인증되지 않음: 채팅 기능은 로그인이 필요합니다');
            }
            break;

          case 4: // 마이페이지 탭 - 인증 필요
            if (isLoggedIn) {
              LoggerUtil.i(
                  '🔄 마이페이지 탭 데이터 새로고침 ${isSameTab ? "(탭 재클릭)" : "(탭 전환)"}');

              // 진행 중인 비동기 요청이 있으면 취소 후 다시 로드
              ref.invalidate(profileProvider);
              ref.invalidate(totalFundingAmountProvider);

              // 쿠폰 데이터 로드
              final couponState = ref.read(couponViewModelProvider);
              final isDefaultTime = couponState.lastUpdated == null ||
                  couponState.lastUpdated!.millisecondsSinceEpoch == 0;

              if (isSameTab || couponState.couponCount <= 0 || isDefaultTime) {
                LoggerUtil.d('🎫 쿠폰 데이터 로드 시작');
                ref.read(couponViewModelProvider.notifier).loadCouponCount();
              }

              // 시간 업데이트
              _tabLoadState.lastMypageLoadTime = now;
              _lastTabRefreshTimes[index] = now;
            } else {
              // 로그인되지 않은 경우, 프로필 관련 Provider들을 명시적으로 초기화
              ref.invalidate(profileProvider);
              ref.invalidate(totalFundingAmountProvider);
              ref.invalidate(myFundingViewModelProvider);
              ref.invalidate(myReviewProvider);
              ref.invalidate(couponViewModelProvider);
              LoggerUtil.d('⚠️ 인증되지 않음: 모든 사용자 프로필 데이터 초기화 완료');
            }
            break;
        }
      } else {
        LoggerUtil.d('🔄 탭 $index 데이터 새로고침 스킵 - 최근에 이미 로드됨');
      }
    } catch (e) {
      LoggerUtil.e('❌ 탭 데이터 새로고침 오류: $e');
    }
  }
}
