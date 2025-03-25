import '../../data/models/funding_model.dart';
import '../../data/repositories/funding_repository.dart';

class GetFundingListUseCase {
  final FundingRepository repository;

  GetFundingListUseCase(this.repository);

  Future<List<FundingModel>> execute(int page) async {
    return await repository.getFundingList(page);
  }
}
