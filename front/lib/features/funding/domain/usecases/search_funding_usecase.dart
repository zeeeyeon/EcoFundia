import '../../data/models/funding_model.dart';

class SearchFundingUseCase {
  final List<FundingModel> allFundingList;

  SearchFundingUseCase(this.allFundingList);

  List<FundingModel> execute(String query) {
    if (query.isEmpty) return allFundingList;
    return allFundingList
        .where((funding) =>
            funding.title.toLowerCase().contains(query.toLowerCase()) ||
            funding.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
