import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_provider.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_view_model.dart';
import 'package:front/features/wishlist/ui/widgets/empty_wishlist.dart';
import 'package:front/features/wishlist/ui/widgets/wishlist_item_card.dart';
import 'package:front/features/wishlist/ui/widgets/wishlist_tab_bar.dart';
import 'package:front/utils/logger_util.dart';

/// 위시리스트 화면
/// 찜한 펀딩 프로젝트를 보여주는 화면
class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWishlistData();
    });

    // 탭 변경 리스너
    _tabController.addListener(() {
      setState(() {}); // 탭 변경 시 UI 업데이트
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 위시리스트 데이터 로드
  void _loadWishlistData() {
    ref.read(wishlistViewModelProvider.notifier).loadWishlistItems();
  }

  /// 상세 페이지로 이동
  void _navigateToProjectDetail(int itemId) {
    // 실제 구현 시 상세 페이지로 이동하는 코드 구현
    LoggerUtil.i('🚀 프로젝트 상세 페이지로 이동: ID $itemId');

    // 예시 - 실제 라우팅은 프로젝트 구조에 따라 구현
    // Navigator.of(context).pushNamed(
    //   '/project-detail',
    //   arguments: {'projectId': itemId},
    // );
  }

  /// 좋아요 토글
  void _toggleLike(int itemId) {
    ref.read(wishlistViewModelProvider.notifier).toggleWishlistItem(itemId);
  }

  @override
  Widget build(BuildContext context) {
    // 위시리스트 상태 조회
    final wishlistState = ref.watch(wishlistViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.black, size: 20),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'My WishList',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true, // iOS 스타일로 중앙 정렬
        actions: [
          // 장바구니 아이콘
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined,
                color: AppColors.black),
            onPressed: () {
              // 장바구니 기능 구현
              LoggerUtil.i('장바구니 버튼 클릭');
            },
          ),
          // 알림 아이콘
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined,
                color: AppColors.black),
            onPressed: () {
              // 알림 기능 구현
              LoggerUtil.i('알림 버튼 클릭');
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
                ),

                // 종료된 탭
                _buildWishlistTab(
                  isLoading: wishlistState.isLoading,
                  items: wishlistState.endedItems,
                  emptyMessage: '찜한 종료된 펀딩이 없습니다.',
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
  }) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (items.isEmpty) {
      return EmptyWishlist(message: emptyMessage);
    }

    // RefreshIndicator로 감싸서 당겨서 새로고침 기능 추가
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () =>
          ref.read(wishlistViewModelProvider.notifier).refreshWishlistItems(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          itemCount: items.length,
          physics: const AlwaysScrollableScrollPhysics(), // 항상 스크롤 가능하도록 설정
          itemBuilder: (context, index) {
            final item = items[index];
            return WishlistItemCard(
              item: item,
              onToggleLike: _toggleLike,
              onParticipate: _navigateToProjectDetail,
            );
          },
        ),
      ),
    );
  }
}
