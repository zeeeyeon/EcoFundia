import 'package:front/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:front/features/wishlist/domain/repositories/wishlist_repository.dart';

/// 종료된 펀딩 위시리스트 조회 유스케이스
class GetEndedWishlistItemsUseCase {
  final WishlistRepository _repository;

  GetEndedWishlistItemsUseCase(this._repository);

  /// 유스케이스 실행
  Future<List<WishlistItemEntity>> execute() async {
    return _repository.getEndedWishlistItems();
  }
}
