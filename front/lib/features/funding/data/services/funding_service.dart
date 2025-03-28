import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/features/funding/data/models/funding_detail_model.dart';
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
    final content = rawData['content'];

    if (content == null || content is! List) {
      return []; // content가 null이거나 리스트가 아니면 빈 리스트 반환
    }

    return content.map((e) => FundingModel.fromJson(e)).toList();
  }

  Future<List<FundingModel>> searchFunding(String query, {int page = 1}) async {
    final response = await api.get(
      '/api/business/search',
      queryParameters: {
        'sort': 'latest',
        'page': 1,
        'keyword': query, // 백엔드 명세서에 따라 'keyword'로!
      },
    );

    final data = response.data['content'];
    if (data == null || data is! List) {
      return []; // null 방어: 리스트 아님 or null이면 빈 리스트 반환
    }

    return data.map((item) => FundingModel.fromJson(item)).toList();
  }

  Future<List<FundingModel>> getSpecialFunding({
    required String topic,
    String sort = 'none',
    int page = 1,
  }) async {
    final response = await api.get(
      '/api/business/search/special',
      queryParameters: {
        'topic': topic,
        'sort': sort,
        'page': page,
      },
    );

    final rawData = response.data;
    final content = rawData['content'];

    if (content == null || content is! List) {
      return []; // content가 null이거나 리스트가 아니면 빈 리스트 반환
    }

    return content.map((e) => FundingModel.fromJson(e)).toList();
  }

  // 펀딩 상세 조회
  Future<FundingDetailModel> fetchFundingDetail(int fundingId) async {
    final response = await api.get('/api/business/detail/$fundingId');
    final data = response.data['content'];
    return FundingDetailModel.fromJson(data);
  }
}
