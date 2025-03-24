import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/data/models/write_review_request.dart';
import 'package:front/features/mypage/data/repositories/write_review_repository.dart';
import 'package:front/features/mypage/data/services/write_review_service.dart';
import '../../../../core/services/api_service.dart';

final writeReviewViewModelProvider =
    StateNotifierProvider<WriteReviewViewModel, AsyncValue<bool>>(
  (ref) {
    final apiService = ref.read(apiServiceProvider); // ✅ 여기로 변경
    final service = WriteReviewService(apiService); // 생성자 수정
    final repository = WriteReviewRepository(service);
    return WriteReviewViewModel(repository);
  },
);

class WriteReviewViewModel extends StateNotifier<AsyncValue<bool>> {
  final WriteReviewRepository _repository;

  WriteReviewViewModel(this._repository) : super(const AsyncData(false));

  Future<void> submitReview(WriteReviewRequest request) async {
    state = const AsyncLoading();
    try {
      final success = await _repository.submitReview(request);
      if (success) {
        state = const AsyncData(true);
      } else {
        state = AsyncError('리뷰 작성에 실패했어요', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
