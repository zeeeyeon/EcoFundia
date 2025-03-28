import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/funding/data/models/funding_detail_model.dart';
import 'package:front/features/funding/data/repositories/funding_repository.dart';
import 'package:front/features/funding/ui/view_model/funding_list_view_model.dart';

final getFundingDetailUseCaseProvider =
    Provider<GetFundingDetailUseCase>((ref) {
  final repository = ref.watch(fundingRepositoryProvider);
  return GetFundingDetailUseCase(repository);
});

class GetFundingDetailUseCase {
  final FundingRepository repository;

  GetFundingDetailUseCase(this.repository);

  Future<FundingDetailModel> execute(int fundingId) {
    return repository.getFundingDetail(fundingId);
  }
}
