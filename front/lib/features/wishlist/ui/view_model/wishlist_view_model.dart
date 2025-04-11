import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:front/features/wishlist/domain/use_cases/get_active_wishlist_items_use_case.dart';
import 'package:front/features/wishlist/domain/use_cases/get_ended_wishlist_items_use_case.dart';
import 'package:front/features/wishlist/domain/use_cases/toggle_wishlist_item_use_case.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/features/wishlist/data/repositories/wishlist_repository_impl.dart'
    hide wishlistRepositoryProvider;
import 'package:flutter/material.dart';
import 'package:front/utils/error_handling_mixin.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:front/core/services/storage_service.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_provider.dart';

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

      try {
        // 병렬로 두 요청 실행
        final activeItemsFuture =
            _getActiveWishlistItemsUseCase.execute(page: 1, size: _pageSize);
        final endedItemsFuture =
            _getEndedWishlistItemsUseCase.execute(page: 1, size: _pageSize);

        // 두 결과 모두 기다림
        final results =
            await Future.wait([activeItemsFuture, endedItemsFuture]);

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
      } catch (apiError) {
        // API 요청 중 오류 발생 - 인증 관련 오류일 수 있음
        LoggerUtil.e('🔄 API 요청 중 오류 발생', apiError);

        // 다시 인증 상태 확인
        final isStillAuthenticated = await StorageService.isAuthenticated();
        if (!isStillAuthenticated) {
          // 인증 토큰이 만료되었거나 유효하지 않은 경우
          state = state.copyWith(
            isLoading: false,
            error: '로그인이 필요하거나 인증이 만료되었습니다. 다시 로그인해 주세요.',
          );
        } else {
          // 그 외 API 오류
          state = state.copyWith(
            isLoading: false,
            error: '위시리스트를 불러오는 중 오류가 발생했습니다.',
          );
        }
        // 에러 상태 설정
        setErrorState(apiError);
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
      {required BuildContext context, required WidgetRef ref}) async {
    // 위시리스트 화면에서는 항상 제거 기능만 수행
    // optimistic UI 업데이트 - 해당 아이템을 UI에서 즉시 제거
    _optimisticUpdateWishStatus(itemId, false);

    try {
      // 명시적으로 removeFromWishlist 호출하여 제거 API만 호출
      await _toggleWishlistItemUseCase.remove(itemId);
      LoggerUtil.i('✅ API 위시리스트 제거 성공: $itemId');

      // --- 중요: 전역 wishlistIdsProvider 상태 업데이트 ---
      try {
        final currentIds = ref.read(wishlistIdsProvider).toSet();
        if (currentIds.remove(itemId)) {
          ref.read(wishlistIdsProvider.notifier).state = currentIds;
          LoggerUtil.d(
              '🔄 전역 wishlistIdsProvider 상태 업데이트: ID $itemId 제거됨. 현재 ID 목록: $currentIds');
        } else {
          LoggerUtil.w('⚠️ 전역 위시리스트 ID 제거 시도 실패: $itemId 가 이미 없거나 오류 발생');
        }
      } catch (e, s) {
        LoggerUtil.e('❌ 전역 위시리스트 ID 제거 동기화 중 오류', e, s);
        // 에러가 발생해도 계속 진행하여 로컬 상태 갱신 시도
      }
      // --- 업데이트 끝 ---

      // 실제 위시리스트 데이터 로드 (로컬 상태 동기화)
      // 전역 상태 업데이트 후, 이 ViewModel의 로컬 상태도 갱신
      await loadWishlistItems();

      // 성공 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('위시리스트에서 제거되었습니다.'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      LoggerUtil.i('✅ 위시리스트 아이템 제거 전체 작업 완료: $itemId');
      return false; // 제거 후에는 항상 false 반환
    } catch (e, s) {
      if (kDebugMode) {
        LoggerUtil.e('❌ 위시리스트 제거 API 호출 실패: 아이템 ID $itemId', e, s);
      }

      // 오류 처리 Mixin 사용
      setErrorState(e);

      // 오류 발생 시 UI 상태 롤백 - 아이템 다시 표시
      // loadWishlistItems()를 호출하여 서버 상태 기준으로 복구 시도
      LoggerUtil.i('🔄 위시리스트 제거 실패, UI 롤백 시도 (loadWishlistItems 호출)');
      _optimisticUpdateWishStatus(itemId, true); // 임시로 롤백 상태 보여주기
      await loadWishlistItems(); // 서버 데이터로 최종 롤백

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

      // 전역 상태 롤백은 loadWishlistIdsProvider 등을 통해 처리되는 것이 이상적
      // 여기서는 직접 롤백하지 않음

      return true; // 오류 발생 시 원래 상태로 복원되었음을 알림
    }
  }

  /// 낙관적 업데이트 (UI 즉시 반영)
  void _optimisticUpdateWishStatus(int itemId, bool isInWishlist) {
    // 현재 로직은 제거만 처리하므로 isInWishlist가 false인 경우만 고려
    if (!isInWishlist) {
      // 기존 로직 유지: 로컬 상태에서 아이템 제거
      final updatedActiveItems =
          state.activeItems.where((item) => item.id != itemId).toList();
      final updatedEndedItems =
          state.endedItems.where((item) => item.id != itemId).toList();

      // 로그 추가: 로컬 상태 변경 전후 확인
      LoggerUtil.d('🔄 Optimistic Update: 로컬 상태에서 ID $itemId 제거 시도');
      LoggerUtil.d(
          '   - 변경 전 active: ${state.activeItems.length}개, ended: ${state.endedItems.length}개');

      state = state.copyWith(
        activeItems: updatedActiveItems,
        endedItems: updatedEndedItems, // 종료된 목록도 업데이트
      );

      LoggerUtil.d(
          '   - 변경 후 active: ${state.activeItems.length}개, ended: ${state.endedItems.length}개');
    } else {
      // 롤백 시나리오: UI에서 임시로 아이템을 다시 보여주기
      // 실제 데이터는 loadWishlistItems()를 통해 복구됨
      LoggerUtil.d(
          '🔄 Optimistic Rollback: UI에서 임시로 ID $itemId 복원 (loadWishlistItems 호출 예정)');
      // 이 부분은 loadWishlistItems()가 결국 상태를 덮어쓰므로,
      // 복잡한 로직 추가 없이 로그만 남기거나, 필요시 간단한 플레이스홀더를 추가할 수 있음
      // 예: state = state.copyWith(activeItems: [...state.activeItems, dummyItem]);
      // 하지만 여기서는 loadWishlistItems()를 신뢰하고 별도 UI 조작은 최소화
    }
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
