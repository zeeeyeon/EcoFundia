import 'package:front/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:front/features/wishlist/domain/repositories/wishlist_repository.dart';

/// 진행 중인 펀딩 위시리스트 조회 유스케이스
class GetActiveWishlistItemsUseCase {
  final WishlistRepository _repository;

  GetActiveWishlistItemsUseCase(this._repository);

  /// 유스케이스 실행
  Future<List<WishlistItemEntity>> execute() async {
    return _repository.getActiveWishlistItems();
  }
}
