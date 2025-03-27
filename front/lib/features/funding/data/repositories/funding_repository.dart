import '../models/funding_model.dart';
import '../services/funding_service.dart';

class FundingRepository {
  final FundingService service;

  FundingRepository(this.service);

  // 펀딩 리스트 가져오기
  Future<List<FundingModel>> getFundingList({
    required int page,
    String sort = 'latest',
    List<String>? categories,
  }) {
    return service.fetchFundingList(
      page: page,
      sort: sort,
      categories: categories,
    );
  }

  Future<List<FundingModel>> searchFunding(String query, {int page = 1}) {
    return service.searchFunding(query);
  }

  Future<List<FundingModel>> fetchSpecialFunding({
    required String topic,
    int page = 1,
  }) {
    return service.getSpecialFunding(topic: topic, page: page);
  }
}
