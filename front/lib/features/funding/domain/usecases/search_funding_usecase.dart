import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/funding/ui/view_model/funding_list_view_model.dart';
import '../../data/models/funding_model.dart';
import '../../data/repositories/funding_repository.dart';

final searchFundingUseCaseProvider = Provider<SearchFundingUseCase>((ref) {
  final repository = ref.watch(fundingRepositoryProvider);
  return SearchFundingUseCase(repository);
});

class SearchFundingUseCase {
  final FundingRepository repository;

  SearchFundingUseCase(this.repository);

  Future<List<FundingModel>> execute(String query) async {
    // query를 서버에 전달해서 검색 요청
    return await repository.searchFunding(query);
  }
}
