import '../../data/repositories/funding_repository.dart';
import '../../data/models/funding_model.dart';

class GetFundingListUseCase {
  final FundingRepository repository;

  GetFundingListUseCase(this.repository);

  Future<List<FundingModel>> execute() async {
    return await repository.getFundingList();
  }
}
