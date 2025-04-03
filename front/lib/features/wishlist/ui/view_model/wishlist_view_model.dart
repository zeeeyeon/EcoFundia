import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:front/features/wishlist/domain/use_cases/get_active_wishlist_items_use_case.dart';
import 'package:front/features/wishlist/domain/use_cases/get_ended_wishlist_items_use_case.dart';
import 'package:front/features/wishlist/domain/use_cases/toggle_wishlist_item_use_case.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:front/utils/error_handling_mixin.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:front/core/services/storage_service.dart';

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
class WishlistViewModel extends StateNotifier<WishlistState>
    with StateNotifierErrorHandlingMixin<WishlistState> {
  final GetActiveWishlistItemsUseCase _getActiveWishlistItemsUseCase;
  final GetEndedWishlistItemsUseCase _getEndedWishlistItemsUseCase;
  final ToggleWishlistItemUseCase _toggleWishlistItemUseCase;
  final int _pageSize = 10; // 페이지당 아이템 수

  // GlobalKey for ScaffoldMessenger to show SnackBar
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

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
    // 이미 로딩 중이면 중복 요청 방지
    if (state.isLoading || state.isRefreshing) {
      if (kDebugMode) {
        LoggerUtil.d('🚫 위시리스트 로드 취소: 이미 로딩 중');
      }
      return;
    }

    startLoading(); // Mixin의 로딩 상태 추적 메서드 사용
    state = state.copyWith(
        isLoading: true,
        error: null,
        activeCurrentPage: 1,
        endedCurrentPage: 1,
        hasMoreActiveItems: true,
        hasMoreEndedItems: true);

    try {
      // 로컬 스토리지에서 인증 상태 확인
      final isAuthenticated = await StorageService.isAuthenticated();

      // 인증되지 않은 경우 API 호출 중단
      if (!isAuthenticated) {
        LoggerUtil.w('⚠️ 위시리스트 로드 취소: 인증되지 않음');
        state = state.copyWith(
          isLoading: false,
          activeItems: const [], // 빈 리스트로 초기화
          endedItems: const [],
          hasMoreActiveItems: false,
          hasMoreEndedItems: false,
        );
        finishLoading(); // 로딩 상태 종료
        return;
      }

      if (kDebugMode) {
        LoggerUtil.i('🔄 위시리스트 API 요청 시작');
      }
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

      if (kDebugMode) {
        LoggerUtil.i(
            '✅ 위시리스트 로드 완료: 진행 중 ${activeItems.length}개, 종료됨 ${endedItems.length}개');
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerUtil.e('❌ 위시리스트 로드 실패', e);
      }
      final errorState = setErrorState(e); // Mixin의 오류 처리 메서드 사용
      state = state.copyWith(
        isLoading: false,
        error: errorState.toString(), // Mixin에서 제공하는 오류 메시지 사용
      );
    } finally {
      finishLoading(); // Mixin의 로딩 상태 종료 메서드 사용
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

  /// 위시리스트에 아이템 토글 (추가/제거)
  Future<bool> toggleWishlistItem(int itemId,
      {required BuildContext context}) async {
    // Optimistic UI 업데이트
    final bool wasInWishlist =
        state.activeItems.any((item) => item.id == itemId) ||
            state.endedItems.any((item) => item.id == itemId);
    _optimisticUpdateWishStatus(itemId, !wasInWishlist);

    try {
      // API 호출
      final result = await _toggleWishlistItemUseCase.execute(itemId);

      // 실제 위시리스트 데이터 로드 (UI 동기화)
      await loadWishlistItems();

      // 성공 메시지 표시 (선택적)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(wasInWishlist ? '위시리스트에서 제거되었습니다.' : '위시리스트에 추가되었습니다.'),
            duration: const Duration(seconds: 1),
          ),
        );
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        LoggerUtil.e('위시리스트 토글 실패: 아이템 ID $itemId', e);
      }

      // 오류 처리 Mixin 사용
      setErrorState(e);

      // 오류 발생 시 UI 상태 롤백
      _revertWishStatus(itemId, wasInWishlist);

      // 오류 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage), // Mixin에서 제공하는 오류 메시지 사용
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      return wasInWishlist;
    }
  }

  /// 낙관적 업데이트 (UI 즉시 반영)
  void _optimisticUpdateWishStatus(int itemId, bool isInWishlist) {
    if (isInWishlist) {
      if (!state.activeItems.any((item) => item.id == itemId)) {
        // WishlistItemEntity 생성 시 필수 파라미터를 가진 더미 데이터를 추가
        // 실제 데이터는 loadWishlistItems()에서 갱신됨
        state = state.copyWith(activeItems: [
          ...state.activeItems,
          WishlistItemEntity(
            id: itemId,
            title: '로딩 중...',
            imageUrl: '',
            rate: 0,
            remainingDays: 0,
            amountGap: 0,
            sellerName: '',
          )
        ]);
      }
    } else {
      state = state.copyWith(
          activeItems:
              state.activeItems.where((item) => item.id != itemId).toList());
    }
  }

  /// 상태 롤백 (API 실패 시)
  void _revertWishStatus(int itemId, bool wasInWishlist) {
    _optimisticUpdateWishStatus(itemId, wasInWishlist);
  }

  /// 에러 메시지 초기화
  void clearError() {
    clearErrorState(); // Mixin의 오류 상태 초기화 메서드 사용
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
