import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:front/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:front/features/wishlist/domain/use_cases/get_active_wishlist_items_use_case.dart';
import 'package:front/features/wishlist/domain/use_cases/get_ended_wishlist_items_use_case.dart';
import 'package:front/features/wishlist/domain/use_cases/toggle_wishlist_item_use_case.dart';
import 'package:front/utils/logger_util.dart';

/// 위시리스트 상태
class WishlistState {
  final bool isLoading;
  final List<WishlistItemEntity> activeItems;
  final List<WishlistItemEntity> endedItems;
  final String? error;

  const WishlistState({
    this.isLoading = false,
    this.activeItems = const [],
    this.endedItems = const [],
    this.error,
  });

  WishlistState copyWith({
    bool? isLoading,
    List<WishlistItemEntity>? activeItems,
    List<WishlistItemEntity>? endedItems,
    String? error,
  }) {
    return WishlistState(
      isLoading: isLoading ?? this.isLoading,
      activeItems: activeItems ?? this.activeItems,
      endedItems: endedItems ?? this.endedItems,
      error: error,
    );
  }
}

/// 위시리스트 뷰모델
class WishlistViewModel extends StateNotifier<WishlistState> {
  final GetActiveWishlistItemsUseCase _getActiveWishlistItemsUseCase;
  final GetEndedWishlistItemsUseCase _getEndedWishlistItemsUseCase;
  final ToggleWishlistItemUseCase _toggleWishlistItemUseCase;

  WishlistViewModel({
    required GetActiveWishlistItemsUseCase getActiveWishlistItemsUseCase,
    required GetEndedWishlistItemsUseCase getEndedWishlistItemsUseCase,
    required ToggleWishlistItemUseCase toggleWishlistItemUseCase,
  })  : _getActiveWishlistItemsUseCase = getActiveWishlistItemsUseCase,
        _getEndedWishlistItemsUseCase = getEndedWishlistItemsUseCase,
        _toggleWishlistItemUseCase = toggleWishlistItemUseCase,
        super(const WishlistState());

  /// 위시리스트 데이터 로드
  Future<void> loadWishlistItems() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 병렬로 두 요청 실행
      final activeItemsFuture = _getActiveWishlistItemsUseCase.execute();
      final endedItemsFuture = _getEndedWishlistItemsUseCase.execute();

      // 두 결과 모두 기다림
      final results = await Future.wait([activeItemsFuture, endedItemsFuture]);

      final activeItems = results[0];
      final endedItems = results[1];

      state = state.copyWith(
        isLoading: false,
        activeItems: activeItems,
        endedItems: endedItems,
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

  /// 좋아요 상태 토글
  Future<void> toggleWishlistItem(int itemId) async {
    try {
      final result = await _toggleWishlistItemUseCase.execute(itemId);

      if (result) {
        // 토글 성공 시 목록 다시 로드
        await loadWishlistItems();
      } else {
        state = state.copyWith(
          error: '위시리스트 항목을 업데이트하는데 실패했습니다.',
        );
      }
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 토글 실패', e);
      state = state.copyWith(
        error: '위시리스트 처리 중 오류가 발생했습니다.',
      );
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

/// 위시리스트 레포지토리 프로바이더
final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  // 여기에서 레포지토리 구현체를 반환
  // 프로젝트 내에서 이미 정의된 레포지토리가 있다면 그것을 사용
  throw UnimplementedError('Provider must be overridden');
});

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
