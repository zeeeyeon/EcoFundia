import '../../data/models/funding_model.dart';
import '../../data/repositories/funding_repository.dart';

class SearchFundingUseCase {
  final FundingRepository repository;

  SearchFundingUseCase(this.repository);

  Future<List<FundingModel>> execute(String query) async {
    // query를 서버에 전달해서 검색 요청
    return await repository.searchFunding(query);
  }
}
