import 'package:front/core/services/api_service.dart';
import '../models/write_review_request.dart';

class WriteReviewService {
  final ApiService _api;

  WriteReviewService(this._api);

  Future<bool> submitReview(WriteReviewRequest request) async {
    try {
      final response =
          await _api.post('api/user/review', data: request.toJson());
      final data = response.data;
      return data['status']['code'] == 'SU';
    } catch (e) {
      print('리뷰 작성 실패: $e');
      return false;
    }
  }
}
