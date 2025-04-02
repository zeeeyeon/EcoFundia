import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/data/models/edit_review_request.dart';
import 'package:front/features/mypage/data/repositories/edit_review_repository.dart';
import 'package:front/features/mypage/data/services/edit_review_service.dart';
import '../../../../core/services/api_service.dart';

final editReviewServiceProvider = Provider((ref) {
  return EditReviewService(ref.read(apiServiceProvider));
});

final editReviewRepositoryProvider = Provider((ref) {
  return EditReviewRepository(ref.read(editReviewServiceProvider));
});

final editReviewViewModelProvider =
    StateNotifierProvider<EditReviewViewModel, AsyncValue<bool>>((ref) {
  return EditReviewViewModel(ref.read(editReviewRepositoryProvider));
});

class EditReviewViewModel extends StateNotifier<AsyncValue<bool>> {
  final EditReviewRepository _repository;

  EditReviewViewModel(this._repository) : super(const AsyncData(false));

  Future<void> updateReview(int reviewId, EditReviewRequest request) async {
    state = const AsyncLoading();
    try {
      await _repository.updateReview(reviewId, request);
      state = const AsyncData(true);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
