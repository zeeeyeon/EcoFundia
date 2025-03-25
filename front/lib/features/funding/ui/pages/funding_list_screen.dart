import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/ui/widgets/custom_app_bar.dart';
import 'package:front/core/ui/widgets/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import '../../ui/view_model/funding_list_view_model.dart';
import '../../ui/widgets/funding_card.dart';

class FundingListScreen extends ConsumerStatefulWidget {
  const FundingListScreen({super.key});

  @override
  _FundingListScreenState createState() => _FundingListScreenState();
}

class _FundingListScreenState extends ConsumerState<FundingListScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool showFilteredResults = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_scrollController.position.outOfRange) {
        ref.read(fundingListProvider.notifier).fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fundingState = ref.watch(fundingListProvider);
    final notifier = ref.read(fundingListProvider.notifier);
    final isFetchingMore = notifier.isFetching;

    return LoadingOverlay(
      isLoading: fundingState is AsyncLoading,
      message: '펀딩 정보를 불러오는 중...',
      child: Scaffold(
        appBar: CustomAppBar(
          showBackButton: false,
          showHomeButton: true,
          showSearchField: true,
          searchController: searchController,
          onSearchChanged: (query) {
            ref.read(searchQueryProvider.notifier).state = query;
            ref.read(fundingListProvider.notifier).searchFunding(query);
          },
          onSearchSubmit: () {
            setState(() {
              showFilteredResults = true;
            });
          },
        ),
        body: fundingState.when(
          loading: () => const SizedBox.shrink(),
          error: (err, _) => Center(child: Text("오류 발생: $err")),
          data: (fundingList) => fundingList.isEmpty
              ? const Center(child: Text(SearchStrings.noResults))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: fundingList.length + (isFetchingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < fundingList.length) {
                      final funding = fundingList[index];
                      return GestureDetector(
                        onTap: () {
                          context.push('/funding/detail', extra: funding);
                        },
                        child: FundingCard(funding: funding),
                      );
                    } else {
                      // 🔽 리스트 하단 로딩 인디케이터
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
        ),
      ),
    );
  }
}
