// lib/features/funding/ui/view_model/search_suggest_view_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/features/funding/data/repositories/suggest_repository.dart';
import 'package:front/features/funding/data/services/%08suggest_service.dart';
import 'package:front/features/funding/domain/usecases/get_suggestions_usecase.dart';

final searchSuggestProvider =
    StateNotifierProvider<SearchSuggestViewModel, List<String>>((ref) {
  final suggestService = SuggestService(ref.read(apiServiceProvider));
  final suggestRepo = SuggestRepository(suggestService);
  final usecase = GetSuggestionsUseCase(suggestRepo);
  return SearchSuggestViewModel(usecase);
});

class SearchSuggestViewModel extends StateNotifier<List<String>> {
  final GetSuggestionsUseCase usecase;

  SearchSuggestViewModel(this.usecase) : super([]);

  Future<void> fetch(String prefix) async {
    if (prefix.trim().isEmpty) {
      state = [];
      return;
    }
    state = await usecase(prefix);
  }

  void clear() => state = [];
}
