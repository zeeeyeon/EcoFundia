import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/funding/data/models/funding_model.dart';
import 'package:front/features/funding/ui/view_model/funding_list_view_model.dart';

final specialFundingProvider = StateNotifierProvider.autoDispose
    .family<SpecialFundingViewModel, AsyncValue<List<FundingModel>>, String>(
  (ref, topic) => SpecialFundingViewModel(ref, topic),
);

class SpecialFundingViewModel
    extends StateNotifier<AsyncValue<List<FundingModel>>> {
  final Ref ref;
  final String topic;
  int _currentPage = 1;
  bool _isFetching = false;
  bool _hasMore = true;

  SpecialFundingViewModel(this.ref, this.topic) : super(const AsyncLoading()) {
    fetch();
  }

  bool get isFetching => _isFetching;
  bool get hasMore => _hasMore;

  Future<void> fetch() async {
    _currentPage = 1;
    _hasMore = true;

    try {
      final result = await ref
          .read(fundingRepositoryProvider)
          .fetchSpecialFunding(topic: topic, page: _currentPage);
      state = AsyncValue.data(result);
      if (result.length < 2) _hasMore = false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> fetchNextPage() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    _currentPage++;

    try {
      final result = await ref
          .read(fundingRepositoryProvider)
          .fetchSpecialFunding(topic: topic, page: _currentPage);

      state = state.whenData((prev) => [...prev, ...result]);
      if (result.length < 2) _hasMore = false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isFetching = false;
    }
  }
}
