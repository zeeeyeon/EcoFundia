import 'package:front/core/services/api_service.dart';

class SuggestService {
  final ApiService apiService;

  SuggestService(this.apiService);

  Future<List<String>> fetchSuggestions(String prefix) async {
    final response =
        await apiService.get('/business/suggest', queryParameters: {
      'prefix': prefix,
    });

    final content = response.data['content'];
    if (content is List) {
      return content
          .map((e) => e['prefix'])
          .whereType<String>() // null 또는 String 아닌 값 제거
          .toList();
    } else {
      return [];
    }
  }
}
