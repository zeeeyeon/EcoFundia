import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/data/models/my_review_model.dart';
import 'package:front/features/mypage/data/repositories/my_review_repository.dart';
import 'package:front/features/mypage/data/services/my_review_service.dart';
import '../../../../core/services/api_service.dart';

final myReviewServiceProvider = Provider(
  (ref) => MyReviewService(ref.read(apiServiceProvider)),
);

final myReviewRepositoryProvider = Provider(
  (ref) => MyReviewRepository(ref.read(myReviewServiceProvider)),
);

final myReviewProvider =
    StateNotifierProvider<MyReviewViewModel, AsyncValue<List<MyReviewModel>>>(
  (ref) => MyReviewViewModel(ref.read(myReviewRepositoryProvider)),
);

class MyReviewViewModel extends StateNotifier<AsyncValue<List<MyReviewModel>>> {
  final MyReviewRepository _repository;

  MyReviewViewModel(this._repository) : super(const AsyncLoading()) {
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      final reviews = await _repository.getMyReviews();
      state = AsyncValue.data(reviews);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      await _repository.deleteReview(reviewId);
      await fetchReviews(); // 삭제 후 리스트 갱신
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
