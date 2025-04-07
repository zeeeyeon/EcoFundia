import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_view_model.dart';
import 'package:front/features/wishlist/ui/widgets/empty_wishlist.dart';
import 'package:front/features/wishlist/ui/widgets/wishlist_item_card.dart';
import 'package:front/features/wishlist/ui/widgets/wishlist_tab_bar.dart';
import 'package:front/utils/logger_util.dart';
import 'package:go_router/go_router.dart';

/// 위시리스트 화면
/// 찜한 펀딩 프로젝트를 보여주는 화면
class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin,
        WidgetsBindingObserver {
  late TabController _tabController;
  final ScrollController _activeScrollController = ScrollController();
  final ScrollController _endedScrollController = ScrollController();
  bool _isActiveLoadingMore = false;
  bool _isEndedLoadingMore = false;
  bool _isPageVisible = true;
  DateTime? _lastWishlistLoadTime; // 마지막 위시리스트 로드 시간 추적

  @override
  bool get wantKeepAlive => false; // 화면 상태 유지하지 않음

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 스크롤 리스너 추가
    _activeScrollController.addListener(_activeScrollListener);
    _endedScrollController.addListener(_endedScrollListener);

    // 앱 라이프사이클 옵저버 등록
    WidgetsBinding.instance.addObserver(this);

    // 탭 변경 리스너
    _tabController.addListener(() {
      setState(() {}); // 탭 변경 시 UI 업데이트
    });

    // 첫 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWishlistData();
    });
  }

  @override
  void dispose() {
    _activeScrollController.removeListener(_activeScrollListener);
    _endedScrollController.removeListener(_endedScrollListener);
    _activeScrollController.dispose();
    _endedScrollController.dispose();
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 포그라운드로 돌아오는 경우
    if (state == AppLifecycleState.resumed && _isPageVisible) {
      _loadWishlistData();
    }
  }

  // GoRouter의 StatefulShellRoute가 탭 변경 시 호출하는 메서드
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 처음 빌드되거나 다시 보여질 때 호출됨

    // 현재 경로가 위시리스트인지 정확히 확인
    final currentRoute = GoRouterState.of(context).uri.path;
    final isWishlistTab = currentRoute == '/wishlist';

    // 디버깅
    LoggerUtil.d(
        '🧪 didChangeDependencies - currentRoute: $currentRoute, isWishlistTab: $isWishlistTab, isPageVisible: $_isPageVisible');

    if (isWishlistTab && !_isPageVisible) {
      _isPageVisible = true;
      LoggerUtil.i('🔄 위시리스트 페이지 활성화 - 데이터 로드');
      _loadWishlistData();
    } else if (!isWishlistTab && _isPageVisible) {
      _isPageVisible = false;
      LoggerUtil.i('🔄 위시리스트 페이지 비활성화');
    }
  }

  /// 위시리스트 데이터 로드
  void _loadWishlistData() {
    // 중복 호출 방지 로직 (3초 이내 중복 호출 무시)
    final now = DateTime.now();
    if (_lastWishlistLoadTime != null &&
        now.difference(_lastWishlistLoadTime!).inSeconds < 3) {
      LoggerUtil.d('🚫 위시리스트 로드 취소: 최근 3초 이내에 이미 요청됨');
      return;
    }
    _lastWishlistLoadTime = now;

    LoggerUtil.i('🔄 위시리스트 데이터 새로 로드');
    ref.read(wishlistViewModelProvider.notifier).loadWishlistItems();
  }

  /// 진행 중인 펀딩 스크롤 리스너
  void _activeScrollListener() {
    if (_isActiveLoadingMore) return;
    if (_activeScrollController.position.pixels >=
        _activeScrollController.position.maxScrollExtent - 300) {
      setState(() {
        _isActiveLoadingMore = true;
      });
      LoggerUtil.i('🔄 진행 중인 펀딩 다음 페이지 로드');
      ref
          .read(wishlistViewModelProvider.notifier)
          .loadMoreActiveItems()
          .then((_) {
        setState(() {
          _isActiveLoadingMore = false;
        });
      });
    }
  }

  /// 종료된 펀딩 스크롤 리스너
  void _endedScrollListener() {
    if (_isEndedLoadingMore) return;
    if (_endedScrollController.position.pixels >=
        _endedScrollController.position.maxScrollExtent - 300) {
      setState(() {
        _isEndedLoadingMore = true;
      });
      LoggerUtil.i('🔄 종료된 펀딩 다음 페이지 로드');
      ref
          .read(wishlistViewModelProvider.notifier)
          .loadMoreEndedItems()
          .then((_) {
        setState(() {
          _isEndedLoadingMore = false;
        });
      });
    }
  }

  /// 상세 페이지로 이동
  void _navigateToProjectDetail(int itemId) {
    LoggerUtil.i('🚀 프로젝트 상세 페이지로 이동: ID $itemId');
    context.push('/project-detail/$itemId');
  }

  /// 좋아요 토글
  void _toggleLike(int itemId) {
    ref
        .read(wishlistViewModelProvider.notifier)
        .toggleWishlistItem(itemId, context: context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 위시리스트 상태 조회
    final wishlistState = ref.watch(wishlistViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
        title: Text(
          AppBarStrings.myWishList,
          style: AppTextStyles.appBarTitle,
        ),
        actions: [
          // 장바구니 아이콘
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined,
                color: AppColors.black),
            onPressed: () {
              context.go('/cart');
            },
          ),
          // 알림 아이콘
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined,
                color: AppColors.black),
            onPressed: () {
              context.go('/notification');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 탭 바
          WishlistTabBar(tabController: _tabController),

          // 탭 뷰
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 진행 중 탭
                _buildWishlistTab(
                  isLoading: wishlistState.isLoading,
                  items: wishlistState.activeItems,
                  emptyMessage: '찜한 진행 중인 펀딩이 없습니다.',
                  scrollController: _activeScrollController,
                  isLoadingMore: _isActiveLoadingMore,
                ),

                // 종료된 탭
                _buildWishlistTab(
                  isLoading: wishlistState.isLoading,
                  items: wishlistState.endedItems,
                  emptyMessage: '찜한 종료된 펀딩이 없습니다.',
                  scrollController: _endedScrollController,
                  isLoadingMore: _isEndedLoadingMore,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 위시리스트 탭 빌드
  Widget _buildWishlistTab({
    required bool isLoading,
    required List items,
    required String emptyMessage,
    required ScrollController scrollController,
    required bool isLoadingMore,
  }) {
    if (isLoading && items.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (items.isEmpty) {
      return EmptyWishlist(message: emptyMessage);
    }

    // RefreshIndicator로 감싸서 당겨서 새로고침 기능 추가
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await ref
            .read(wishlistViewModelProvider.notifier)
            .refreshWishlistItems();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          controller: scrollController,
          itemCount: items.length + (isLoadingMore ? 1 : 0),
          physics: const AlwaysScrollableScrollPhysics(), // 항상 스크롤 가능하도록 설정
          itemBuilder: (context, index) {
            if (index == items.length) {
              // 마지막 아이템 로딩 인디케이터
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            final item = items[index];
            return WishlistItemCard(
              item: item,
              onToggleLike: _toggleLike,
              onParticipate: _navigateToProjectDetail,
              onNavigateToDetail: _navigateToProjectDetail,
            );
          },
        ),
      ),
    );
  }
}
