import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/data/models/write_review_request.dart';
import 'package:front/features/mypage/data/repositories/write_review_repository.dart';
import 'package:front/features/mypage/data/services/write_review_service.dart';
import 'package:front/core/services/api_service.dart';

// Provider 설정
final writeReviewServiceProvider = Provider<WriteReviewService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return WriteReviewService(apiService);
});

final writeReviewRepositoryProvider = Provider<WriteReviewRepository>((ref) {
  final service = ref.read(writeReviewServiceProvider);
  return WriteReviewRepository(service);
});

final writeReviewViewModelProvider =
    StateNotifierProvider<WriteReviewViewModel, AsyncValue<bool>>((ref) {
  final repository = ref.read(writeReviewRepositoryProvider);
  return WriteReviewViewModel(repository);
});

// ViewModel
class WriteReviewViewModel extends StateNotifier<AsyncValue<bool>> {
  final WriteReviewRepository _repository;

  WriteReviewViewModel(this._repository) : super(const AsyncData(false));

  Future<void> submitReview(WriteReviewRequest request) async {
    state = const AsyncLoading();
    try {
      await _repository.submitReview(request);
      state = const AsyncData(true);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
