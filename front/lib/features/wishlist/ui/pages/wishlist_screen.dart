import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_view_model.dart';
import 'package:front/features/wishlist/ui/widgets/empty_wishlist.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/features/wishlist/ui/widgets/wishlist_item_card.dart';
import 'package:front/features/wishlist/ui/widgets/wishlist_tab_bar.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:go_router/go_router.dart';

/// 위시리스트 화면
/// 찜한 펀딩 프로젝트를 보여주는 화면
class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin,
        WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true; // 화면을 캐시하여 상태 유지

  late final TabController _tabController;
  final ScrollController _activeScrollController = ScrollController();
  final ScrollController _endedScrollController = ScrollController();

  bool _isActiveLoadingMore = false;
  bool _isEndedLoadingMore = false;
  bool _isPageVisible = false;
  DateTime? _lastWishlistLoadTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 스크롤 리스너 등록
    _activeScrollController.addListener(_activeScrollListener);
    _endedScrollController.addListener(_endedScrollListener);

    // 앱 라이프사이클 변경 감지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIsWishlistTab();
    });

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
    _tabController.dispose();
    _activeScrollController.removeListener(_activeScrollListener);
    _endedScrollController.removeListener(_endedScrollListener);
    _activeScrollController.dispose();
    _endedScrollController.dispose();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkIsWishlistTab();
  }

  /// 탭 가시성 확인 및 데이터 로드
  void _checkIsWishlistTab() {
    final isWishlistTab = ModalRoute.of(context)?.isCurrent ?? false;

    // 탭이 보이게 되면 데이터 로드
    if (isWishlistTab && !_isPageVisible) {
      _isPageVisible = true;
      LoggerUtil.i('🔄 위시리스트 페이지 활성화');
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
    context.push('/project/$itemId');
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

    // 로그인 상태 확인
    final isLoggedIn = ref.watch(isLoggedInProvider);

    // 로그인하지 않은 경우 로그인 안내 화면 표시
    if (!isLoggedIn) {
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
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.favorite_border,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                '로그인이 필요한 서비스입니다',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '로그인하시면 관심있는 펀딩 프로젝트를\n찜 목록에 저장하실 수 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.push('/login');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                ),
                child: const Text('로그인 하기'),
              ),
            ],
          ),
        ),
      );
    }

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

  /// 위시리스트 탭 화면 구성
  Widget _buildWishlistTab({
    required bool isLoading,
    required List items,
    required String emptyMessage,
    required ScrollController scrollController,
    required bool isLoadingMore,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        LoggerUtil.i('🔄 위시리스트 수동 새로고침');
        await ref.read(wishlistViewModelProvider.notifier).loadWishlistItems();
      },
      child: isLoading && items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? EmptyWishlist(message: emptyMessage)
              : ListView.builder(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: items.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    // 하단 로딩 인디케이터
                    if (index == items.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: WishlistItemCard(
                        item: item,
                        onToggleLike: _toggleLike,
                        onParticipate: _navigateToProjectDetail,
                        onNavigateToDetail: _navigateToProjectDetail,
                      ),
                    );
                  },
                ),
    );
  }

  @override
  void didUpdateWidget(WishlistScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}
