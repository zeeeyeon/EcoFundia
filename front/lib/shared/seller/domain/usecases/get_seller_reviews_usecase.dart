import 'package:front/shared/seller/domain/entities/review_entity.dart';
import 'package:front/shared/seller/domain/repositories/seller_repository.dart';

/// 판매자 리뷰 목록을 가져오는 유스케이스
class GetSellerReviewsUseCase {
  final SellerRepository _repository;

  GetSellerReviewsUseCase(this._repository);

  /// 판매자 리뷰 목록 로드
  Future<List<ReviewEntity>> execute(int sellerId) async {
    return await _repository.getSellerReviews(sellerId);
  }
}
