import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/data/models/my_review_model.dart';
import 'package:front/features/mypage/data/repositories/my_review_repository.dart';
import 'package:front/features/mypage/data/services/my_review_service.dart';

final myReviewViewModelProvider =
    StateNotifierProvider<MyReviewViewModel, AsyncValue<List<MyReviewModel>>>(
  (ref) {
    final service = MyReviewService();
    final repository = MyReviewRepository(service);
    return MyReviewViewModel(repository);
  },
);

class MyReviewViewModel extends StateNotifier<AsyncValue<List<MyReviewModel>>> {
  final MyReviewRepository _repository;

  MyReviewViewModel(this._repository) : super(const AsyncLoading()) {
    fetchMyReviews();
  }

  Future<void> fetchMyReviews() async {
    try {
      final reviews = await _repository.getMyReviews();
      state = AsyncValue.data(reviews);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
