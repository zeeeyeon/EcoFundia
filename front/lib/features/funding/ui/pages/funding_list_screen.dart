import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/ui/widgets/custom_app_bar.dart';
import 'package:front/core/ui/widgets/loading_overlay.dart';
import 'package:go_router/go_router.dart';

import '../../ui/view_model/funding_list_view_model.dart';
import '../../data/models/funding_model.dart';
import '../../ui/widgets/funding_card.dart';

class FundingListScreen extends ConsumerStatefulWidget {
  const FundingListScreen({super.key});

  @override
  _FundingListScreenState createState() => _FundingListScreenState();
}

class _FundingListScreenState extends ConsumerState<FundingListScreen> {
  final TextEditingController searchController = TextEditingController();
  bool showFilteredResults = false;

  @override
  Widget build(BuildContext context) {
    final fundingState = ref.watch(fundingListProvider);

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
          loading: () => const SizedBox.shrink(), // 이미 로딩 오버레이로 처리됨
          error: (err, _) => Center(child: Text("오류 발생: $err")),
          data: (fundingList) => fundingList.isEmpty
              ? const Center(child: Text(SearchStrings.noResults))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: fundingList.length,
                  itemBuilder: (context, index) {
                    final funding = fundingList[index];
                    return GestureDetector(
                      onTap: () {
                        context.push('/funding/detail', extra: funding);
                      },
                      child: FundingCard(funding: funding),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
