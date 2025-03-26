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

  // 추후 검색 기능 등도 여기에 추가할 수 있음
  Future<List<FundingModel>> searchFunding(String query) {
    return service.searchFunding(query);
  }
}
