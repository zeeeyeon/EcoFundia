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
  final int _lastSelectedIndex = 0; // 초기값은 0 (홈 탭 인덱스에 따라 조정)

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
      final appState = ref.read(appStateProvider);
      final isLoggedIn = appState.isLoggedIn;
      final now = DateTime.now();
      final isSameTab = index == previousIndex;
      DateTime? lastRefreshTime = _lastTabRefreshTimes[index];

      // 새로고침 필요 여부 결정 (다른 탭에서 왔거나, 같은 탭 재클릭 시에는 항상, 또는 일정 시간 경과 시)
      final isRefreshNeeded = !isSameTab ||
          isSameTab || // Same tab click always triggers refresh attempt
          lastRefreshTime == null ||
          now.difference(lastRefreshTime).inSeconds >
              _minRefreshIntervalSeconds;

      LoggerUtil.d('🔒 탭 $index 선택됨 - 이전 탭: $previousIndex');
      LoggerUtil.d(
          '🔒 탭 $index 새로고침 조건 - 필요: $isRefreshNeeded, 인증: $isLoggedIn, 같은 탭: $isSameTab');

      // 새로고침 필요한 경우에만 로직 실행
      if (isRefreshNeeded) {
        LoggerUtil.i('🔄 탭 $index 데이터 새로고침 시작...');
        bool updatedTime = false; // 시간 업데이트 여부 플래그

        // ViewModel 새로고침 로직
        switch (index) {
          case 0: // 펀딩 탭
            ref.read(fundingListProvider.notifier).fetchFundingList(
                  page: 1,
                  sort: ref.read(sortOptionProvider), // 현재 정렬 유지
                  categories:
                      ref.read(selectedCategoriesProvider), // 현재 카테고리 유지
                );
            if (isLoggedIn) {
              final _ = ref.refresh(loadWishlistIdsProvider);
            }
            updatedTime = true;
            break;

          case 1: // 찜 탭
            if (isLoggedIn) {
              ref.read(wishlistViewModelProvider.notifier).loadWishlistItems();
              final _ = ref.refresh(loadWishlistIdsProvider);
              updatedTime = true;
            } else {
              ref.read(wishlistViewModelProvider.notifier).resetState();
              LoggerUtil.w('🔒 찜 탭: 로그인 필요 - 상태 초기화');
              // 로그인 안됐을 땐 새로고침 시간 업데이트 안함 (다음에 바로 로드되도록)
            }
            break;

          case 2: // 홈 탭
            ref.read(projectViewModelProvider.notifier).refreshProjects();
            if (isLoggedIn) {
              final _ = ref.refresh(loadWishlistIdsProvider);
            }
            updatedTime = true;
            break;

          case 3: // 채팅 탭
            if (isLoggedIn) {
              // ChatRoomListViewModel에 새로고침 메서드(예: fetchChatRooms) 호출 필요
              ref.read(chatRoomListProvider.notifier).fetchChatRooms();
              updatedTime = true;
            } else {
              // 채팅 관련 상태 초기화 필요시 진행
              LoggerUtil.w('🔒 채팅 탭: 로그인 필요');
            }
            break;

          case 4: // 마이페이지 탭
            if (isLoggedIn) {
              ref.read(profileProvider.notifier).fetchProfile();
              final _ = ref.refresh(totalFundingAmountProvider);
              // CouponViewModel에 새로고침 메서드 확인 필요
              ref
                  .read(couponViewModelProvider.notifier)
                  .loadCouponList(); // 수정: Provider 사용 및 메서드 호출 (예: loadCouponList 또는 refreshCoupons)
              updatedTime = true;
            } else {
              // 마이페이지 관련 상태 초기화
              // ref.read(profileProvider.notifier).resetState(); // resetState 메서드 확인 필요
              LoggerUtil.w('🔒 마이페이지 탭: 로그인 필요');
            }
            break;
        }

        // 데이터 로드를 시도했다면 마지막 새로고침 시간 업데이트
        if (updatedTime) {
          _lastTabRefreshTimes[index] = now;
          LoggerUtil.i('✅ 탭 $index 새로고침 완료, 시간 기록');
        }
      } else {
        LoggerUtil.d('🚫 탭 $index 데이터 새로고침 건너뜀 (조건 미충족)');
      }
    } catch (e, s) {
      LoggerUtil.e('❌ 탭 데이터 새로고침 중 오류 발생', e, s);
    }
  }
}
