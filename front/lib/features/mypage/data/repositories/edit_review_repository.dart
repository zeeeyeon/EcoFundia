import '../models/edit_review_request.dart';
import '../services/edit_review_service.dart';

class EditReviewRepository {
  final EditReviewService _service;

  EditReviewRepository(this._service);

  Future<void> updateReview(int reviewId, EditReviewRequest request) {
    return _service.updateReview(reviewId, request);
  }
}
