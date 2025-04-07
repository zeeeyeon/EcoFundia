import 'package:front/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:front/utils/logger_util.dart';

/// 위시리스트 ID 목록을 가져오는 UseCase
class GetWishlistIdsUseCase {
  final WishlistRepository _repository;

  GetWishlistIdsUseCase(this._repository);

  /// 위시리스트 ID 목록 조회 실행
  Future<List<int>> execute() async {
    try {
      LoggerUtil.d('🔍 위시리스트 ID 목록 UseCase 실행');
      // WishlistApiService의 getWishlistFundingIds() 메서드 사용
      final ids = await _repository.getWishlistFundingIds();
      LoggerUtil.d('✅ 위시리스트 ID 목록 UseCase 완료: ${ids.length}개');
      return ids;
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 ID 목록 UseCase 실패', e);
      rethrow;
    }
  }
}
