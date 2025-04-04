import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/data/models/my_review_model.dart';
import 'package:front/features/mypage/data/repositories/my_review_repository.dart';
import 'package:front/features/mypage/data/services/my_review_service.dart';
import '../../../../core/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:front/utils/logger_util.dart';

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
  final CancelToken _cancelToken = CancelToken();

  MyReviewViewModel(this._repository) : super(const AsyncLoading()) {
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      if (_cancelToken.isCancelled) {
        LoggerUtil.d('🔄 리뷰 조회 - 취소된 토큰 재생성');
      }

      final reviews = await _repository.getMyReviews(cancelToken: _cancelToken);

      if (mounted) {
        state = AsyncValue.data(reviews);
      }
    } catch (e, st) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        LoggerUtil.i('🛑 리뷰 조회 요청이 취소되었습니다.');
        return;
      }

      if (mounted) {
        state = AsyncValue.error(e, st);
        LoggerUtil.e('❌ 리뷰 조회 실패', e);
      }
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      await _repository.deleteReview(reviewId, cancelToken: _cancelToken);

      if (mounted) {
        await fetchReviews();
      }
    } catch (e, st) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        LoggerUtil.i('🛑 리뷰 삭제 요청이 취소되었습니다.');
        return;
      }

      if (mounted) {
        state = AsyncValue.error(e, st);
        LoggerUtil.e('❌ 리뷰 삭제 실패', e);
      }
    }
  }

  @override
  void dispose() {
    if (!_cancelToken.isCancelled) {
      LoggerUtil.i('🛑 MyReviewViewModel dispose - 진행 중인 요청 취소');
      _cancelToken.cancel('ViewModel이 dispose되어 요청 취소');
    }
    super.dispose();
  }
}
