import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/ui/widgets/custom_app_bar.dart';
import 'package:front/features/funding/ui/widgets/category_filter_widget.dart';
import 'package:front/features/funding/ui/widgets/sort_dropdown_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/funding/ui/view_model/funding_list_view_model.dart';
import 'package:front/features/funding/ui/widgets/funding_card.dart';
import 'package:front/features/funding/data/models/funding_model.dart';
import 'package:front/utils/logger_util.dart';

class FundingListScreen extends ConsumerStatefulWidget {
  const FundingListScreen({super.key});

  @override
  _FundingListScreenState createState() => _FundingListScreenState();
}

class _FundingListScreenState extends ConsumerState<FundingListScreen> {
  final ScrollController _scrollController = ScrollController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fundingState = ref.watch(fundingListProvider);
    final notifier = ref.read(fundingListProvider.notifier);
    final isFetchingMore = notifier.isFetching;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        showSearchField: true,
        onSearchTap: () {
          context.push('/funding/search');
        },
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: AppColors.textDark),
            onPressed: () => context.go('/'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const CategoryFilterWidget(),
          const SizedBox(height: 12),
          const SortDropdownWidget(),
          const SizedBox(height: 16),
          Expanded(
            child: fundingState.when(
              loading: () => fundingState.hasValue &&
                      fundingState.value!.isNotEmpty
                  ? _buildFundingList(fundingState.value!, isFetchingMore)
                  : const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text("오류 발생: $err")),
              data: (fundingList) {
                if (fundingList.isEmpty && !isFetchingMore) {
                  return const Center(child: Text(SearchStrings.noResults));
                }
                return _buildFundingList(fundingList, isFetchingMore);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundingList(
      List<FundingModel> fundingList, bool isFetchingMore) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: fundingList.length + (isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < fundingList.length) {
          final funding = fundingList[index];
          return GestureDetector(
            onTap: () {
              LoggerUtil.d('펀딩 목록 아이템 클릭: ${funding.fundingId}');
              context.push('/project/${funding.fundingId}');
            },
            child: FundingCard(funding: funding),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
      },
    );
  }
}
