import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/api_service.dart';
import '../../data/models/funding_model.dart';
import '../../data/services/funding_service.dart';
import '../../data/repositories/funding_repository.dart';
import '../../domain/usecases/get_funding_list_usecase.dart';

// 서비스 Provider
final fundingServiceProvider = Provider(
  (ref) => FundingService(ref.read(apiServiceProvider)),
);

// 레포지토리 Provider
final fundingRepositoryProvider = Provider(
  (ref) => FundingRepository(ref.read(fundingServiceProvider)),
);

// 추가 로딩 상태 Provider
final isFetchingMoreProvider = StateProvider<bool>((ref) => false);

// 정렬 기준 상태 (latest, oldest, popular 등)
final sortOptionProvider = StateProvider<String>((ref) => 'latest');

// 선택된 카테고리 상태 (빈 배열이면 전체)
final selectedCategoriesProvider = StateProvider<List<String>>((ref) => []);

// 펀딩 리스트 상태 Provider
final fundingListProvider =
    StateNotifierProvider<FundingListNotifier, AsyncValue<List<FundingModel>>>(
  (ref) {
    final repository = ref.read(fundingRepositoryProvider);
    final getFundingListUseCase = GetFundingListUseCase(repository);

    return FundingListNotifier(
      ref: ref,
      getFundingListUseCase: getFundingListUseCase,
    )..fetchFundingList(
        page: 1,
        sort: ref.read(sortOptionProvider),
        categories: ref.read(selectedCategoriesProvider),
      ); // 앱 시작 시 펀딩 리스트 로드
  },
);

class FundingListNotifier
    extends StateNotifier<AsyncValue<List<FundingModel>>> {
  final Ref ref;
  final GetFundingListUseCase getFundingListUseCase;

  FundingListNotifier({
    required this.ref,
    required this.getFundingListUseCase,
  }) : super(const AsyncLoading());

  int _currentPage = 1;
  bool _isFetching = false;
  bool _hasMore = true; // 끝났는지 여부

  bool get isFetching => _isFetching;

  // 펀딩 리스트 호출 (페이지 0 기준)
  Future<void> fetchFundingList({
    required int page,
    required String sort,
    List<String>? categories,
  }) async {
    state = const AsyncLoading();
    _currentPage = 1;
    _hasMore = true;
    _isFetching = false;

    try {
      final fundings = await getFundingListUseCase.execute(
        page,
        sort: sort,
        categories: categories,
      );
      state = AsyncValue.data(fundings);
      if (fundings.length < 2) _hasMore = false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // 스크롤 시 다음 페이지 호출
  Future<void> fetchNextPage() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    _currentPage++;

    try {
      final sort = ref.read(sortOptionProvider);
      final categories = ref.read(selectedCategoriesProvider);

      final newFundings = await getFundingListUseCase.execute(
        _currentPage,
        sort: sort,
        categories: categories,
      );

      state = state.whenData((existing) => [...existing, ...newFundings]);
      if (newFundings.length < 2) _hasMore = false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isFetching = false;
    }
  }
}
