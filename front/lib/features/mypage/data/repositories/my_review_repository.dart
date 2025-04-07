import '../models/my_review_model.dart';
import '../services/my_review_service.dart';
import 'package:dio/dio.dart';

class MyReviewRepository {
  final MyReviewService _service;

  MyReviewRepository(this._service);

  Future<List<MyReviewModel>> getMyReviews({CancelToken? cancelToken}) async {
    return await _service.fetchMyReviews(cancelToken: cancelToken);
  }

  Future<void> deleteReview(int reviewId, {CancelToken? cancelToken}) async {
    await _service.deleteReview(reviewId, cancelToken: cancelToken);
  }
}
