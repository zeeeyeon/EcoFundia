import '../models/write_review_request.dart';
import '../services/write_review_service.dart';

class WriteReviewRepository {
  final WriteReviewService _service;

  WriteReviewRepository(this._service);

  Future<bool> submitReview(WriteReviewRequest request) async {
    return await _service.submitReview(request);
  }
}
