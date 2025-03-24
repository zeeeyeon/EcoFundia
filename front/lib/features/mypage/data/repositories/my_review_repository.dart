import '../models/my_review_model.dart';
import '../services/my_review_service.dart';

class MyReviewRepository {
  final MyReviewService _service;

  MyReviewRepository(this._service);

  Future<List<MyReviewModel>> getMyReviews() async {
    return await _service.fetchMyReviews();
  }
}

// 💡 지금은 단순히 Service를 감싸지만,
// 추후에는 캐싱, 오류 처리, API 리트라이, 복수 source 병합 등 확장 가능!
