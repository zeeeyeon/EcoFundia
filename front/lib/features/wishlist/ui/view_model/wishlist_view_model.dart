import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:front/features/wishlist/domain/use_cases/get_active_wishlist_items_use_case.dart';
import 'package:front/features/wishlist/domain/use_cases/get_ended_wishlist_items_use_case.dart';
import 'package:front/features/wishlist/domain/use_cases/toggle_wishlist_item_use_case.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/features/wishlist/data/repositories/wishlist_repository_impl.dart';

/// 위시리스트 상태
class WishlistState {
  final bool isLoading;
  final bool isRefreshing;
  final List<WishlistItemEntity> activeItems;
  final List<WishlistItemEntity> endedItems;
  final String? error;
  final int activeCurrentPage;
  final int endedCurrentPage;
  final bool hasMoreActiveItems;
  final bool hasMoreEndedItems;

  const WishlistState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.activeItems = const [],
    this.endedItems = const [],
    this.error,
    this.activeCurrentPage = 1,
    this.endedCurrentPage = 1,
    this.hasMoreActiveItems = true,
    this.hasMoreEndedItems = true,
  });

  WishlistState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<WishlistItemEntity>? activeItems,
    List<WishlistItemEntity>? endedItems,
    String? error,
    int? activeCurrentPage,
    int? endedCurrentPage,
    bool? hasMoreActiveItems,
    bool? hasMoreEndedItems,
  }) {
    return WishlistState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      activeItems: activeItems ?? this.activeItems,
      endedItems: endedItems ?? this.endedItems,
      error: error,
      activeCurrentPage: activeCurrentPage ?? this.activeCurrentPage,
      endedCurrentPage: endedCurrentPage ?? this.endedCurrentPage,
      hasMoreActiveItems: hasMoreActiveItems ?? this.hasMoreActiveItems,
      hasMoreEndedItems: hasMoreEndedItems ?? this.hasMoreEndedItems,
    );
  }
}

/// 위시리스트 뷰모델
class WishlistViewModel extends StateNotifier<WishlistState> {
  final GetActiveWishlistItemsUseCase _getActiveWishlistItemsUseCase;
  final GetEndedWishlistItemsUseCase _getEndedWishlistItemsUseCase;
  final ToggleWishlistItemUseCase _toggleWishlistItemUseCase;
  final int _pageSize = 10; // 페이지당 아이템 수

  WishlistViewModel({
    required GetActiveWishlistItemsUseCase getActiveWishlistItemsUseCase,
    required GetEndedWishlistItemsUseCase getEndedWishlistItemsUseCase,
    required ToggleWishlistItemUseCase toggleWishlistItemUseCase,
  })  : _getActiveWishlistItemsUseCase = getActiveWishlistItemsUseCase,
        _getEndedWishlistItemsUseCase = getEndedWishlistItemsUseCase,
        _toggleWishlistItemUseCase = toggleWishlistItemUseCase,
        super(const WishlistState());

  /// 위시리스트 데이터 로드 (첫 페이지)
  Future<void> loadWishlistItems() async {
    state = state.copyWith(
        isLoading: true,
        error: null,
        activeCurrentPage: 1,
        endedCurrentPage: 1,
        hasMoreActiveItems: true,
        hasMoreEndedItems: true);

    try {
      // 병렬로 두 요청 실행
      final activeItemsFuture =
          _getActiveWishlistItemsUseCase.execute(page: 1, size: _pageSize);
      final endedItemsFuture =
          _getEndedWishlistItemsUseCase.execute(page: 1, size: _pageSize);

      // 두 결과 모두 기다림
      final results = await Future.wait([activeItemsFuture, endedItemsFuture]);

      final activeItems = results[0];
      final endedItems = results[1];

      // 더 불러올 데이터가 있는지 확인
      final hasMoreActiveItems = activeItems.length >= _pageSize;
      final hasMoreEndedItems = endedItems.length >= _pageSize;

      state = state.copyWith(
        isLoading: false,
        activeItems: activeItems,
        endedItems: endedItems,
        hasMoreActiveItems: hasMoreActiveItems,
        hasMoreEndedItems: hasMoreEndedItems,
      );

      LoggerUtil.i(
          '✅ 위시리스트 로드 완료: 진행 중 ${activeItems.length}개, 종료됨 ${endedItems.length}개');
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 로드 실패', e);
      state = state.copyWith(
        isLoading: false,
        error: '위시리스트를 불러오는데 실패했습니다.',
      );
    }
  }

  /// 진행 중인 위시리스트 아이템 더 불러오기
  Future<void> loadMoreActiveItems() async {
    // 더 불러올 아이템이 없거나 이미 로딩 중이면 종료
    if (!state.hasMoreActiveItems || state.isLoading || state.isRefreshing) {
      return;
    }

    try {
      final nextPage = state.activeCurrentPage + 1;
      LoggerUtil.i('🔄 진행 중인 위시리스트 $nextPage페이지 로드 시작');

      final newItems = await _getActiveWishlistItemsUseCase.execute(
          page: nextPage, size: _pageSize);

      // 더 불러올 데이터가 있는지 확인
      final hasMoreItems = newItems.length >= _pageSize;

      // 이전 아이템과 새 아이템 합치기
      final updatedItems = [...state.activeItems, ...newItems];

      state = state.copyWith(
        activeItems: updatedItems,
        activeCurrentPage: nextPage,
        hasMoreActiveItems: hasMoreItems,
      );

      LoggerUtil.i('✅ 진행 중인 위시리스트 더 불러오기 완료: ${newItems.length}개 추가');
    } catch (e) {
      LoggerUtil.e('❌ 진행 중인 위시리스트 더 불러오기 실패', e);
      state = state.copyWith(
        error: '위시리스트를 더 불러오는데 실패했습니다.',
      );
    }
  }

  /// 종료된 위시리스트 아이템 더 불러오기
  Future<void> loadMoreEndedItems() async {
    // 더 불러올 아이템이 없거나 이미 로딩 중이면 종료
    if (!state.hasMoreEndedItems || state.isLoading || state.isRefreshing) {
      return;
    }

    try {
      final nextPage = state.endedCurrentPage + 1;
      LoggerUtil.i('🔄 종료된 위시리스트 $nextPage페이지 로드 시작');

      final newItems = await _getEndedWishlistItemsUseCase.execute(
          page: nextPage, size: _pageSize);

      // 더 불러올 데이터가 있는지 확인
      final hasMoreItems = newItems.length >= _pageSize;

      // 이전 아이템과 새 아이템 합치기
      final updatedItems = [...state.endedItems, ...newItems];

      state = state.copyWith(
        endedItems: updatedItems,
        endedCurrentPage: nextPage,
        hasMoreEndedItems: hasMoreItems,
      );

      LoggerUtil.i('✅ 종료된 위시리스트 더 불러오기 완료: ${newItems.length}개 추가');
    } catch (e) {
      LoggerUtil.e('❌ 종료된 위시리스트 더 불러오기 실패', e);
      state = state.copyWith(
        error: '위시리스트를 더 불러오는데 실패했습니다.',
      );
    }
  }

  /// pull-to-refresh 용 새로고침 메서드
  Future<void> refreshWishlistItems() async {
    if (state.isLoading || state.isRefreshing) return;

    state = state.copyWith(
        isRefreshing: true,
        error: null,
        activeCurrentPage: 1,
        endedCurrentPage: 1,
        hasMoreActiveItems: true,
        hasMoreEndedItems: true);

    try {
      // 병렬로 두 요청 실행
      final activeItemsFuture =
          _getActiveWishlistItemsUseCase.execute(page: 1, size: _pageSize);
      final endedItemsFuture =
          _getEndedWishlistItemsUseCase.execute(page: 1, size: _pageSize);

      // 두 결과 모두 기다림
      final results = await Future.wait([activeItemsFuture, endedItemsFuture]);

      final activeItems = results[0];
      final endedItems = results[1];

      // 더 불러올 데이터가 있는지 확인
      final hasMoreActiveItems = activeItems.length >= _pageSize;
      final hasMoreEndedItems = endedItems.length >= _pageSize;

      state = state.copyWith(
        isRefreshing: false,
        activeItems: activeItems,
        endedItems: endedItems,
        hasMoreActiveItems: hasMoreActiveItems,
        hasMoreEndedItems: hasMoreEndedItems,
      );

      LoggerUtil.i(
          '✅ 위시리스트 새로고침 완료: 진행 중 ${activeItems.length}개, 종료됨 ${endedItems.length}개');
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 새로고침 실패', e);
      state = state.copyWith(
        isRefreshing: false,
        error: '위시리스트 새로고침에 실패했습니다.',
      );
    }
  }

  /// 좋아요 상태 토글
  Future<void> toggleWishlistItem(int itemId) async {
    // 원본 상태 저장 (실패 시 롤백을 위함)
    final originalActiveItems =
        List<WishlistItemEntity>.from(state.activeItems);
    final originalEndedItems = List<WishlistItemEntity>.from(state.endedItems);

    // 아이템 찾기
    WishlistItemEntity? itemToUpdate;

    int itemIndex = state.activeItems.indexWhere((item) => item.id == itemId);

    if (itemIndex != -1) {
      itemToUpdate = state.activeItems[itemIndex];
    } else {
      itemIndex = state.endedItems.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        itemToUpdate = state.endedItems[itemIndex];
      }
    }

    if (itemToUpdate == null) {
      LoggerUtil.w('⚠️ 토글할 아이템을 찾을 수 없습니다: $itemId');
      return;
    }

    try {
      // 1. Optimistic UI 업데이트 - 아이템 즉시 제거
      _updateItemLikeStatus(itemId);
      LoggerUtil.d('🔄 낙관적 UI 업데이트: 아이템 $itemId 제거됨');

      // 2. API 호출 - 위시리스트 화면에서는 모든 아이템이 이미 찜한 상태이므로 항상 제거 요청을 보냄
      final result = await _toggleWishlistItemUseCase.remove(itemId);

      if (result) {
        LoggerUtil.i('✅ API 성공: 위시리스트 아이템 $itemId 제거 완료');
      } else {
        throw Exception('아이템 제거 실패');
      }
    } catch (e) {
      LoggerUtil.e('❌ API 오류: 위시리스트 토글 실패 $itemId', e);

      // 3. 실패 시 UI 롤백
      state = state.copyWith(
        activeItems: originalActiveItems,
        endedItems: originalEndedItems,
        error: '위시리스트 항목을 업데이트하는데 실패했습니다.',
      );
    }
  }

  /// 아이템 좋아요 상태 업데이트 (낙관적 UI 업데이트용)
  void _updateItemLikeStatus(int itemId) {
    final activeItemIndex =
        state.activeItems.indexWhere((item) => item.id == itemId);
    if (activeItemIndex != -1) {
      final updatedActiveItems =
          List<WishlistItemEntity>.from(state.activeItems);
      updatedActiveItems.removeAt(activeItemIndex);
      state = state.copyWith(activeItems: updatedActiveItems);
      return;
    }

    final endedItemIndex =
        state.endedItems.indexWhere((item) => item.id == itemId);
    if (endedItemIndex != -1) {
      final updatedEndedItems = List<WishlistItemEntity>.from(state.endedItems);
      updatedEndedItems.removeAt(endedItemIndex);
      state = state.copyWith(endedItems: updatedEndedItems);
      return;
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  /// 상태 초기화
  void resetState() {
    state = const WishlistState();
  }
}

/// 위시리스트 레포지토리 프로바이더
// 이미 lib/features/wishlist/data/repositories/wishlist_repository_impl.dart에 정의되어 있으므로 주석 처리
//
// final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
//   final wishlistService = ref.watch(wishlistServiceProvider);
//   return WishlistRepositoryImpl(wishlistService: wishlistService);
// });

/// 유스케이스 프로바이더들
final getActiveWishlistItemsUseCaseProvider =
    Provider<GetActiveWishlistItemsUseCase>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return GetActiveWishlistItemsUseCase(repository);
});

final getEndedWishlistItemsUseCaseProvider =
    Provider<GetEndedWishlistItemsUseCase>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return GetEndedWishlistItemsUseCase(repository);
});

final toggleWishlistItemUseCaseProvider =
    Provider<ToggleWishlistItemUseCase>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return ToggleWishlistItemUseCase(repository);
});

/// 위시리스트 뷰모델 프로바이더
final wishlistViewModelProvider =
    StateNotifierProvider<WishlistViewModel, WishlistState>((ref) {
  return WishlistViewModel(
    getActiveWishlistItemsUseCase:
        ref.watch(getActiveWishlistItemsUseCaseProvider),
    getEndedWishlistItemsUseCase:
        ref.watch(getEndedWishlistItemsUseCaseProvider),
    toggleWishlistItemUseCase: ref.watch(toggleWishlistItemUseCaseProvider),
  );
});
