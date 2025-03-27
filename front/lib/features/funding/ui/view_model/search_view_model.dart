import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/funding/data/models/funding_model.dart';
import 'package:front/features/funding/domain/usecases/search_funding_usecase.dart';

final searchResultProvider = StateNotifierProvider.autoDispose<SearchViewModel,
    AsyncValue<List<FundingModel>>>(
  (ref) {
    final searchFundingUseCase = ref.watch(searchFundingUseCaseProvider);
    return SearchViewModel(searchFundingUseCase);
  },
);

class SearchViewModel extends StateNotifier<AsyncValue<List<FundingModel>>> {
  final SearchFundingUseCase _searchFundingUseCase;
  Timer? _debounce;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetching = false;
  String _currentQuery = '';

  SearchViewModel(this._searchFundingUseCase)
      : super(const AsyncValue.data([]));

  bool get isFetching => _isFetching;
  bool get hasMore => _hasMore;

  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      // 검색어가 바뀌면 초기화
      _currentQuery = query;
      _currentPage = 1;
      _hasMore = true;
      _isFetching = true;

      state = const AsyncValue.loading();
      try {
        final result =
            await _searchFundingUseCase.execute(query, page: _currentPage);
        state = AsyncValue.data(result);
        if (result.length < 2) _hasMore = false;
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      } finally {
        _isFetching = false;
      }
    });
  }

  Future<void> fetchNextPage() async {
    if (_isFetching || !_hasMore || _currentQuery.isEmpty) return;

    _isFetching = true;
    _currentPage++;

    try {
      final result = await _searchFundingUseCase.execute(
        _currentQuery,
        page: _currentPage,
      );
      state = state.whenData((existing) => [...existing, ...result]);

      if (result.length < 2) _hasMore = false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isFetching = false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
