import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/api_service.dart';
import '../models/funding_model.dart';

final fundingServiceProvider = Provider<FundingService>((ref) {
  final api = ref.read(apiServiceProvider);
  return FundingService(api);
});

class FundingService {
  final ApiService api;

  FundingService(this.api);

  // 펀딩 리스트 가져오기
  Future<List<FundingModel>> fetchFundingList({
    required int page,
    String sort = 'latest',
    List<String>? categories,
  }) async {
    final Map<String, dynamic> queryParams = {
      'sort': sort,
      'page': page.toString(),
    };

    // 카테고리가 있다면 각각 개별 키로 추가
    if (categories != null && categories.isNotEmpty) {
      for (var category in categories) {
        queryParams.putIfAbsent('categories', () => <String>[]).add(category);
      }
    }

    final response = await api.get(
      '/api/business/funding-page',
      queryParameters: queryParams,
    );

    final rawData = response.data;
    final content = rawData['content'] as List;

    return content.map((e) => FundingModel.fromJson(e)).toList();
  }

  Future<List<FundingModel>> searchFunding(String query) async {
    final response = await api.get(
      '/api/business/search',
      queryParameters: {
        'sort': 'latest',
        'page': 1,
        'keyword': query, // ✅ 백엔드 명세서에 따라 'keyword'로!
      },
    );

    final List<dynamic> data = response.data['content'];
    return data.map((item) => FundingModel.fromJson(item)).toList();
  }
}
