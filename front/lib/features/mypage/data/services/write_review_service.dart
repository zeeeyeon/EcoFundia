import 'package:front/core/services/api_service.dart';
import '../models/write_review_request.dart';

class WriteReviewService {
  final ApiService _apiService;

  WriteReviewService(this._apiService);

  Future<void> submitReview(WriteReviewRequest request) async {
    await _apiService.post(
      '/user/review',
      data: request.toJson(),
    );
  }
}
