import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:front/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/features/wishlist/data/services/wishlist_api_service.dart';
import 'package:front/core/services/api_service.dart';

/// 위시리스트 리포지토리 구현
class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistService _wishlistService;

  WishlistRepositoryImpl({
    required WishlistService wishlistService,
  }) : _wishlistService = wishlistService;

  /// 진행 중인 펀딩 위시리스트 조회
  @override
  Future<List<WishlistItemEntity>> getActiveWishlist(
      {int page = 1, int size = 10}) async {
    try {
      // API는 0-based 페이지네이션 사용
      final apiPage = page - 1;
      final items =
          await _wishlistService.fetchActiveWishlist(page: apiPage, size: size);
      LoggerUtil.i(
          '✅ 진행 중인 펀딩 위시리스트 조회 완료: ${items.length}개 (페이지: $page, 크기: $size)');
      return items;
    } catch (e) {
      LoggerUtil.e('❌ 진행 중인 펀딩 위시리스트 조회 실패', e);
      throw Exception('위시리스트 조회에 실패했습니다: $e');
    }
  }

  /// 종료된 펀딩 위시리스트 조회
  @override
  Future<List<WishlistItemEntity>> getEndedWishlist(
      {int page = 1, int size = 10}) async {
    try {
      // API는 0-based 페이지네이션 사용
      final apiPage = page - 1;
      final items =
          await _wishlistService.fetchEndedWishlist(page: apiPage, size: size);
      LoggerUtil.i(
          '✅ 종료된 펀딩 위시리스트 조회 완료: ${items.length}개 (페이지: $page, 크기: $size)');
      return items;
    } catch (e) {
      LoggerUtil.e('❌ 종료된 펀딩 위시리스트 조회 실패', e);
      throw Exception('위시리스트 조회에 실패했습니다: $e');
    }
  }

  /// 위시리스트에 추가
  Future<bool> addToWishlist(int itemId) async {
    try {
      await _wishlistService.addToWishlist(itemId);
      LoggerUtil.i('✅ 위시리스트 추가 완료: $itemId');
      return true;
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 추가 실패', e);
      return false;
    }
  }

  /// 위시리스트에서 아이템 제거
  @override
  Future<bool> removeFromWishlist(int itemId) async {
    try {
      await _wishlistService.removeFromWishlist(itemId);
      LoggerUtil.i('✅ 위시리스트 제거 완료: $itemId');
      return true;
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 제거 실패', e);
      return false;
    }
  }

  /// 위시리스트 아이템 좋아요 상태 토글
  @override
  Future<bool> toggleLike(int itemId) async {
    try {
      // 토글 기능은 기존 상태를 확인해야 하지만,
      // API 명세상 isLiked 값이 없어서 직접 상태 확인은 어려움
      // 이 경우 현재 상태를 viewModel에서 관리하고 해당 상태에 따라
      // addToWishlist나 removeFromWishlist를 호출하는 것이 좋음

      // 현재의 구현에서는 일단 추가 시도 후 성공 여부 반환
      // (실제 구현에서는 viewModel에서 현재 isLiked 상태에 따라 분기)
      LoggerUtil.w(
          '⚠️ toggleLike는 직접 호출하지 말고 viewModel에서 상태에 따라 add/remove를 호출하세요');
      return addToWishlist(itemId);
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 토글 실패', e);
      return false;
    }
  }
}

/// WishlistService Provider
final wishlistServiceProvider = Provider<WishlistService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return WishlistApiService(apiService.dio);
});

/// WishlistRepository Provider
final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final wishlistService = ref.watch(wishlistServiceProvider);
  return WishlistRepositoryImpl(wishlistService: wishlistService);
});
