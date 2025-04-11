import '../../../../core/services/api_service.dart';
import '../models/edit_review_request.dart';

class EditReviewService {
  final ApiService _apiService;

  EditReviewService(this._apiService);

  Future<void> updateReview(int reviewId, EditReviewRequest request) async {
    await _apiService.put('/user/review/$reviewId', data: request.toJson());
  }
}
