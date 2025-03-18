import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/funding_repository.dart';
import '../../data/services/funding_service.dart';
import '../../data/models/funding_model.dart';
import '../../domain/usecases/get_funding_list_usecase.dart';
import '../../domain/usecases/search_funding_usecase.dart';

final fundingListProvider =
    StateNotifierProvider<FundingListViewModel, AsyncValue<List<FundingModel>>>(
  (ref) => FundingListViewModel(
    GetFundingListUseCase(FundingRepository(FundingService())),
  ),
);

final searchQueryProvider = StateProvider<String>((ref) => "");

class FundingListViewModel
    extends StateNotifier<AsyncValue<List<FundingModel>>> {
  final GetFundingListUseCase _getFundingListUseCase;
  List<FundingModel> _allFundingList = []; // 원본 리스트

  FundingListViewModel(this._getFundingListUseCase)
      : super(const AsyncValue.loading()) {
    fetchFundingList();
  }

  Future<void> fetchFundingList() async {
    try {
      state = const AsyncValue.loading();
      final fundingList = await _getFundingListUseCase.execute();
      _allFundingList = fundingList;
      state = AsyncValue.data(fundingList);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // 🔥 검색 기능을 UseCase로 분리
  void searchFunding(String query) {
    final searchUseCase = SearchFundingUseCase(_allFundingList);
    state = AsyncValue.data(searchUseCase.execute(query));
  }
}
