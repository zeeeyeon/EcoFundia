import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/funding/data/models/funding_detail_model.dart';
import 'package:front/features/funding/domain/usecases/get_funding_detail_usecase.dart';

final fundingDetailProvider = StateNotifierProvider.autoDispose
    .family<FundingDetailViewModel, AsyncValue<FundingDetailModel>, int>(
  (ref, fundingId) {
    final useCase = ref.read(getFundingDetailUseCaseProvider);
    return FundingDetailViewModel(useCase, fundingId);
  },
);

class FundingDetailViewModel
    extends StateNotifier<AsyncValue<FundingDetailModel>> {
  final GetFundingDetailUseCase _useCase;
  final int fundingId;

  FundingDetailViewModel(this._useCase, this.fundingId)
      : super(const AsyncLoading()) {
    fetchFundingDetail();
  }

  Future<void> fetchFundingDetail() async {
    try {
      final detail = await _useCase.execute(fundingId);
      state = AsyncValue.data(detail);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
