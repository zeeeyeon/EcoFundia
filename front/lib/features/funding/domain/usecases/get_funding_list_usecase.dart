import '../../data/models/funding_model.dart';
import '../../data/repositories/funding_repository.dart';

class GetFundingListUseCase {
  final FundingRepository repository;

  GetFundingListUseCase(this.repository);

  Future<List<FundingModel>> execute(
    int page, {
    String sort = 'latest',
    List<String>? categories,
  }) {
    return repository.getFundingList(
      page: page,
      sort: sort,
      categories: categories,
    );
  }
}
