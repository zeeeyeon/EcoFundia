import 'package:front/features/wishlist/domain/repositories/wishlist_repository.dart';

/// 위시리스트 아이템 토글 유스케이스
class ToggleWishlistItemUseCase {
  final WishlistRepository _repository;

  ToggleWishlistItemUseCase(this._repository);

  /// 유스케이스 실행
  Future<bool> execute(int itemId) async {
    return _repository.toggleWishlistItem(itemId);
  }
}
