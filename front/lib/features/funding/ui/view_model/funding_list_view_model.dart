import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/api_service.dart';
import '../../data/models/funding_model.dart';
import '../../data/services/funding_service.dart';
import '../../data/repositories/funding_repository.dart';
import '../../domain/usecases/get_funding_list_usecase.dart';
import '../../domain/usecases/search_funding_usecase.dart';

// 서비스 Provider
final fundingServiceProvider = Provider(
  (ref) => FundingService(ref.read(apiServiceProvider)),
);

// 레포지토리 Provider
final fundingRepositoryProvider = Provider(
  (ref) => FundingRepository(ref.read(fundingServiceProvider)),
);

// 검색어 상태 Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// 펀딩 리스트 상태 Provider
final fundingListProvider =
    StateNotifierProvider<FundingListNotifier, AsyncValue<List<FundingModel>>>(
  (ref) {
    final repository = ref.read(fundingRepositoryProvider);
    final getFundingListUseCase = GetFundingListUseCase(repository);
    final searchFundingUseCase = SearchFundingUseCase(repository);

    return FundingListNotifier(
      getFundingListUseCase: getFundingListUseCase,
      searchFundingUseCase: searchFundingUseCase,
    )..fetchFundingList(); // 앱 시작 시 펀딩 리스트 로드
  },
);

class FundingListNotifier
    extends StateNotifier<AsyncValue<List<FundingModel>>> {
  final GetFundingListUseCase getFundingListUseCase;
  final SearchFundingUseCase searchFundingUseCase;

  FundingListNotifier({
    required this.getFundingListUseCase,
    required this.searchFundingUseCase,
  }) : super(const AsyncLoading());

  // ✅ 펀딩 리스트 호출 (페이지 0 기준)
  Future<void> fetchFundingList({int page = 0}) async {
    try {
      state = const AsyncLoading();
      final fundings = await getFundingListUseCase.execute(page);
      state = AsyncValue.data(fundings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // 검색 기능
  Future<void> searchFunding(String query) async {
    try {
      state = const AsyncLoading();
      final result = await searchFundingUseCase.execute(query);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
