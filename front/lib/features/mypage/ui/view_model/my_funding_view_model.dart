import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/features/mypage/data/models/my_funding_model.dart';
import 'package:front/features/mypage/data/repositories/my_funding_repository.dart';
import 'package:front/features/mypage/data/services/my_funding_service.dart';
import 'package:dio/dio.dart';
import 'package:front/utils/logger_util.dart';

final myFundingServiceProvider = Provider<MyFundingService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return MyFundingService(apiService);
});

final myFundingRepositoryProvider = Provider<MyFundingRepository>((ref) {
  final service = ref.read(myFundingServiceProvider);
  return MyFundingRepository(service);
});

final myFundingViewModelProvider =
    StateNotifierProvider<MyFundingViewModel, AsyncValue<List<MyFundingModel>>>(
  (ref) => MyFundingViewModel(ref.read(myFundingRepositoryProvider)),
);

class MyFundingViewModel
    extends StateNotifier<AsyncValue<List<MyFundingModel>>> {
  final MyFundingRepository _repository;
  final CancelToken _cancelToken = CancelToken();

  MyFundingViewModel(this._repository) : super(const AsyncLoading()) {
    fetchMyFundings();
  }

  Future<void> fetchMyFundings() async {
    try {
      if (_cancelToken.isCancelled) {
        LoggerUtil.d('🔄 펀딩 조회 - 취소된 토큰 재생성');
      }

      final fundings =
          await _repository.getMyFundings(cancelToken: _cancelToken);

      if (mounted) {
        state = AsyncValue.data(fundings);
      }
    } catch (e, st) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        LoggerUtil.i('🛑 펀딩 조회 요청이 취소되었습니다.');
        return;
      }

      if (mounted) {
        state = AsyncValue.error(e, st);
        LoggerUtil.e('❌ 펀딩 조회 실패', e);
      }
    }
  }

  @override
  void dispose() {
    if (!_cancelToken.isCancelled) {
      LoggerUtil.i('🛑 MyFundingViewModel dispose - 진행 중인 요청 취소');
      _cancelToken.cancel('ViewModel이 dispose되어 요청 취소');
    }
    super.dispose();
  }
}
