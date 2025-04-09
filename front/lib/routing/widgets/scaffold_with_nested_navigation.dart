import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/features/funding/ui/view_model/funding_list_view_model.dart';
import 'package:front/features/home/ui/view_model/project_view_model.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_view_model.dart';
import 'package:front/features/mypage/ui/view_model/profile_view_model.dart';
import 'package:front/features/mypage/ui/view_model/total_funding_provider.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_provider.dart';
import 'package:front/features/mypage/ui/view_model/coupon_view_model.dart';
import 'package:front/features/chat/ui/view_model/chat_room_list_view_model.dart'; // 채팅 ViewModel 추가
import 'package:front/utils/logger_util.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/themes/app_shadows.dart';

// ScaffoldWithNavBar는 StatefulWidget이어야 Timer 및 상태 관리가 용이합니다.
class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  // StatefulNavigationShell은 필수 매개변수입니다.
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  // 디바운싱을 위한 Timer 인스턴스
  Timer? _debounce;
  // 각 탭별 마지막 새로고침 시간 저장 (Stateful 위젯 상태로 관리)
  final Map<int, DateTime> _lastTabRefreshTimes = {};
  // 마지막으로 선택된 탭 인덱스
  int _lastSelectedIndex = 0; // 초기값은 0 (홈 탭 인덱스에 따라 조정)

  // 새로고침 간격 (초)
  static const int _minRefreshIntervalSeconds = 60;

  @override
  void dispose() {
    // 위젯이 dispose될 때 Timer도 취소합니다.
    _debounce?.cancel();
    super.dispose();
  }

  // 네비게이션 쉘을 포함하는 컨테이너에 고유 키 부여
  final GlobalKey _shellContainerKey = GlobalKey(debugLabel: 'shell_container');

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
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: AppColors.white,
              height: 65,
              indicatorColor: Colors.transparent,
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(
                      color: AppColors.primary, size: 26);
                }
                return const IconThemeData(color: AppColors.grey, size: 24);
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final style = AppTextStyles.caption.copyWith(fontSize: 10);
                if (states.contains(WidgetState.selected)) {
                  return style.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600);
                }
                return style.copyWith(color: AppColors.grey);
              }),
            ),
            child: Container(
              // 그림자 효과를 위해 Container로 감쌈
              decoration: const BoxDecoration(
                color: AppColors.white,
                boxShadow: [AppShadows.card],
              ),
              child: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) {
                  // 디바운싱: 짧은 시간 내 중복 탭 방지
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 200), () {
                    final previousIndex = currentIndex;
                    widget.navigationShell.goBranch(
                      index,
                      initialLocation: index == previousIndex,
                    );
                    _refreshTabData(ref, index, previousIndex);
                  });
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.store_outlined),
                    selectedIcon:
                        Icon(Icons.store), // selectedIcon 색상은 Theme에서 관리
                    label: '펀딩',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.favorite_border),
                    selectedIcon: Icon(Icons.favorite),
                    label: '찜',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: '홈',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.chat_bubble_outline),
                    selectedIcon: Icon(Icons.chat_bubble),
                    label: '채팅',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: '마이페이지',
                  ),
                ],
              ),
            ),
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
        // 찜/채팅 탭의 경우, 각 화면 내부에서 리디렉션 로직 처리
      }

      // 마지막 로드 시간 확인 - 로컬 상태 사용
      DateTime? lastRefreshTime = _lastTabRefreshTimes[index];

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
              _lastTabRefreshTimes[index] = now;
            } else {
              // 로그인되지 않은 경우, 위시리스트 상태를 명시적으로 초기화
              ref.read(wishlistViewModelProvider.notifier).resetState();
              LoggerUtil.w('🔒 찜 탭: 로그인 필요 - 데이터 로드 건너뛰고 상태 초기화');
            }
            break;

          case 2: // 홈 탭 - 인증 불필요
            LoggerUtil.i('🔄 홈 탭 데이터 새로고침 ${isSameTab ? "(탭 재클릭)" : "(탭 전환)"}');
            // 홈 화면 관련 Provider 새로고침
            ref.invalidate(projectViewModelProvider);

            // 위시리스트 ID 로드 (로그인 된 경우에만)
            if (isLoggedIn) {
              final loadWishlistIds = ref.read(loadWishlistIdsProvider);
              loadWishlistIds();
            }

            // 시간 업데이트
            _lastTabRefreshTimes[index] = now;
            break;

          case 3: // 채팅 탭 - 인증 필요
            if (isLoggedIn) {
              LoggerUtil.i(
                  '🔄 채팅 탭 데이터 새로고침 ${isSameTab ? "(탭 재클릭)" : "(탭 전환)"}');
              // 채팅 목록 데이터 로드
              ref.read(chatRoomListProvider.notifier).fetchChatRooms();

              // 시간 업데이트
              _lastTabRefreshTimes[index] = now;
            } else {
              // 로그인 안 된 경우 채팅방 목록 상태를 초기화
              ref.read(chatRoomListProvider.notifier).resetState();
              LoggerUtil.w('🔒 채팅 탭: 로그인 필요 - 데이터 로드 건너뛰고 상태 초기화');
              // 로그인 페이지 리디렉션은 ChatScreen 위젯 내부에서 처리
            }
            break;

          case 4: // 마이페이지 탭 - 인증 필요
            if (isLoggedIn) {
              LoggerUtil.i(
                  '🔄 마이페이지 탭 데이터 새로고침 ${isSameTab ? "(탭 재클릭)" : "(탭 전환)"}');
              // 프로필, 펀딩 총액, 쿠폰 개수 등 새로고침
              ref.invalidate(profileProvider);
              ref.invalidate(totalFundingAmountProvider);
              ref
                  .read(couponViewModelProvider.notifier)
                  .loadCouponCount(forceRefresh: true);

              // 시간 업데이트
              _lastTabRefreshTimes[index] = now;
            } else {
              LoggerUtil.w('🔒 마이페이지 탭: 로그인 필요 - 데이터 로드 건너뛰기');
              // 마이페이지 화면 내부에서 로그인 안내 화면 표시
            }
            break;
        }
      }
    } catch (e) {
      LoggerUtil.e('❌ 탭 데이터 새로고침 중 오류 발생: $e');
    }
  }
}
