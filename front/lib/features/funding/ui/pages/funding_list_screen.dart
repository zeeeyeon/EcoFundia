import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../ui/view_model/funding_list_view_model.dart';
import '../../data/models/funding_model.dart';
import '../../ui/widgets/funding_card.dart';

class FundingListScreen extends ConsumerWidget {
  const FundingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fundingState = ref.watch(fundingListProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("펀딩 리스트")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "펀딩 검색...",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (query) {
                ref.read(searchQueryProvider.notifier).state =
                    query; // 검색어 상태 업데이트
                ref
                    .read(fundingListProvider.notifier)
                    .searchFunding(query); // 검색 실행
              },
            ),
          ),
          Expanded(
            child: fundingState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("오류 발생: $err")),
              data: (fundingList) => fundingList.isEmpty
                  ? const Center(child: Text("검색 결과가 없습니다."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: fundingList.length,
                      itemBuilder: (context, index) {
                        FundingModel funding = fundingList[index];
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
        ],
      ),
    );
  }
}
