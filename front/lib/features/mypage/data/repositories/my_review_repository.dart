import '../models/my_review_model.dart';
import '../services/my_review_service.dart';

class MyReviewRepository {
  final MyReviewService _service;

  MyReviewRepository(this._service);

  Future<List<MyReviewModel>> getMyReviews() async {
    return await _service.fetchMyReviews();
  }
}
