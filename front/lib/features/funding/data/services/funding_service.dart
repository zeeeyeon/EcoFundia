import 'package:dio/dio.dart';
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

  // 최신 펀딩 리스트 가져오기
  Future<List<FundingModel>> fetchFundingList(int page) async {
    try {
      final response = await api.get('/api/business/latest-funding/$page');
      final List<dynamic> content = response.data['content'];

      return content.map((json) => FundingModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('펀딩 리스트 요청 실패: ${e.message}');
    }
  }

  Future<List<FundingModel>> searchFunding(String query) async {
    final response =
        await api.get('/api/business/funding/search', queryParameters: {
      'q': query,
    });

    final List<dynamic> data = response.data['content'];
    return data.map((item) => FundingModel.fromJson(item)).toList();
  }
}
