import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/data/models/my_funding_model.dart';
import 'package:front/features/mypage/data/repositories/my_funding_repository.dart';
import 'package:front/features/mypage/data/services/my_funding_service.dart';

final myFundingViewModelProvider =
    StateNotifierProvider<MyFundingViewModel, AsyncValue<List<MyFundingModel>>>(
  (ref) => MyFundingViewModel(MyFundingRepository(MyFundingService())),
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
