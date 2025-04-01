import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/features/mypage/data/models/my_funding_model.dart';
import 'package:front/features/mypage/data/repositories/my_funding_repository.dart';
import 'package:front/features/mypage/data/services/my_funding_service.dart';

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

  MyFundingViewModel(this._repository) : super(const AsyncLoading()) {
    fetchMyFundings();
  }

  Future<void> fetchMyFundings() async {
    try {
      final fundings = await _repository.getMyFundings();
      state = AsyncValue.data(fundings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
