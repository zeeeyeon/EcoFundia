import 'package:front/features/wishlist/domain/entities/wishlist_item_entity.dart';

/// 위시리스트 리포지토리 인터페이스
/// 위시리스트 데이터 처리를 위한 추상화된 인터페이스
abstract class WishlistRepository {
  /// 진행 중인 펀딩 위시리스트 조회
  Future<List<WishlistItemEntity>> getActiveWishlist(
      {int page = 1, int size = 10});

  /// 종료된 펀딩 위시리스트 조회
  Future<List<WishlistItemEntity>> getEndedWishlist(
      {int page = 1, int size = 10});

  /// 위시리스트 아이템 좋아요 상태 토글
  Future<bool> toggleLike(int itemId);

  /// 위시리스트에서 아이템 제거
  Future<bool> removeFromWishlist(int itemId);

  /// 위시리스트에 있는 펀딩 ID 목록 조회
  Future<List<int>> getWishlistFundingIds();
}
