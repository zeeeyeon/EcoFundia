import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/funding/data/models/funding_model.dart';
import 'package:front/features/funding/ui/widgets/funding_card.dart';

class SearchFundingList extends StatelessWidget {
  final List<FundingModel> fundingList;
  final ScrollController scrollController;
  final bool isFetching;

  const SearchFundingList({
    super.key,
    required this.fundingList,
    required this.scrollController,
    required this.isFetching,
  });

  @override
  Widget build(BuildContext context) {
    if (fundingList.isEmpty) {
      return const Center(child: Text("검색 결과가 없습니다."));
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: fundingList.length + (isFetching ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < fundingList.length) {
          final funding = fundingList[index];
          return GestureDetector(
            onTap: () => context.push('/funding/detail', extra: funding),
            child: FundingCard(funding: funding),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
