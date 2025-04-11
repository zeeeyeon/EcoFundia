import '../../data/repositories/suggest_repository.dart';

class GetSuggestionsUseCase {
  final SuggestRepository repository;

  GetSuggestionsUseCase(this.repository);

  Future<List<String>> call(String prefix) {
    return repository.getSuggestions(prefix);
  }
}
