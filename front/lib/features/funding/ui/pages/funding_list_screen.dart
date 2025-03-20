import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
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

    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: false, // 뒤로가기 버튼
        showHomeButton: true, // 홈 버튼
        showSearchField: true, // 검색 필드
        searchController: searchController,
        onSearchChanged: (query) {
          ref.read(searchQueryProvider.notifier).state = query; // 색어 상태 업데이트
          ref.read(fundingListProvider.notifier).searchFunding(query); // 검색 실행
        },
        onSearchSubmit: () {
          setState(() {
            showFilteredResults = true; // 검색 버튼 클릭 시 필터링된 리스트만 보이게 설정
          });
        },
      ),
      body: Expanded(
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
    );
  }
}
