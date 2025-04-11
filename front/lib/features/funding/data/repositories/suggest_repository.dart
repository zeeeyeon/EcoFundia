import 'package:front/features/funding/data/services/suggest_service.dart';

class SuggestRepository {
  final SuggestService service;

  SuggestRepository(this.service);

  Future<List<String>> getSuggestions(String prefix) {
    return service.fetchSuggestions(prefix);
  }
}
