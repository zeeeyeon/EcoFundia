import 'package:front/features/wishlist/domain/repositories/wishlist_repository.dart';

/// 위시리스트 아이템 토글 유스케이스
class ToggleWishlistItemUseCase {
  final WishlistRepository _repository;

  ToggleWishlistItemUseCase(this._repository);

  /// 유스케이스 실행 - 토글
  Future<bool> execute(int itemId) async {
    return _repository.toggleLike(itemId);
  }

  /// 유스케이스 실행 - 명시적으로 추가
  Future<bool> add(int itemId) async {
    // WishlistRepository에서 구현한 addToWishlist 메서드가 있다면 그것을 사용
    if ((_repository as dynamic).addToWishlist != null) {
      return await (_repository as dynamic).addToWishlist(itemId);
    }
    // 없다면 토글 사용
    return _repository.toggleLike(itemId);
  }

  /// 유스케이스 실행 - 명시적으로 제거
  Future<bool> remove(int itemId) async {
    return _repository.removeFromWishlist(itemId);
  }
}
