import '../../../../core/services/api_service.dart';
import '../models/my_review_model.dart';
import 'package:dio/dio.dart';

class MyReviewService {
  final ApiService _apiService;

  MyReviewService(this._apiService);

  Future<List<MyReviewModel>> fetchMyReviews({CancelToken? cancelToken}) async {
    final response = await _apiService.get(
      '/user/review',
      cancelToken: cancelToken,
    );
    final List<dynamic> dataList = response.data['content']['content'];
    return dataList.map((json) => MyReviewModel.fromJson(json)).toList();
  }

  Future<void> deleteReview(int reviewId, {CancelToken? cancelToken}) async {
    await _apiService.delete(
      '/user/review/$reviewId',
      cancelToken: cancelToken,
    );
  }
}
