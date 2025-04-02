import '../../../../core/services/api_service.dart';
import '../models/my_review_model.dart';

class MyReviewService {
  final ApiService _apiService;

  MyReviewService(this._apiService);

  Future<List<MyReviewModel>> fetchMyReviews() async {
    final response = await _apiService.get('/user/review');

    final List<dynamic> dataList = response.data['content']['content'];

    return dataList.map((json) => MyReviewModel.fromJson(json)).toList();
  }
}
