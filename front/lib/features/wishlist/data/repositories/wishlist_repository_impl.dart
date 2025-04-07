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
      // 토글 기능은 완전히 별도의 API 엔드포인트를 호출하도록 개선
      // 현재는 API가 분리되어 있어 이 메서드를 직접 호출하지 않는 것을 권장
      LoggerUtil.w('⚠️ 위시리스트에서 toggleLike는 직접 호출하지 말고, '
          'remove/add 메서드를 호출하세요. 현재는 항상 remove를 호출합니다.');

      // 호출된 경우 위시리스트 화면에서는 항상 제거 동작 수행
      await _wishlistService.removeFromWishlist(itemId);
      LoggerUtil.i('✅ 위시리스트 제거 완료 (toggleLike 메서드로 호출): $itemId');
      return false; // 제거 후에는 항상 false 반환
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 토글 실패', e);
      throw Exception('위시리스트 토글에 실패했습니다: $e');
    }
  }

  /// 위시리스트에 있는 펀딩 ID 목록 조회
  @override
  Future<List<int>> getWishlistFundingIds() async {
    try {
      final wishlistIds = await _wishlistService.getWishlistFundingIds();
      LoggerUtil.i('✅ 위시리스트 펀딩 ID 목록 조회 완료: ${wishlistIds.length}개');
      return wishlistIds;
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 펀딩 ID 목록 조회 실패', e);
      // 오류 발생 시 빈 목록 반환 (좋아요 기능에 영향을 최소화하기 위함)
      return [];
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
