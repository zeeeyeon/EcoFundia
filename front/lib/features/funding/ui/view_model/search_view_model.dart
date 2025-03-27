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

  SearchViewModel(this._searchFundingUseCase)
      : super(const AsyncValue.data([]));

  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      state = const AsyncValue.loading();
      try {
        final result = await _searchFundingUseCase.execute(query);
        state = AsyncValue.data(result);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
