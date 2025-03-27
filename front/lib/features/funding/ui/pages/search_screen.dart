import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/ui/widgets/custom_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/funding/ui/view_model/search_view_model.dart';
import 'package:front/features/funding/ui/widgets/funding_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultState = ref.watch(searchResultProvider);

    return Scaffold(
      appBar: CustomAppBar(
          showBackButton: true,
          showSearchField: true,
          isSearchEnabled: true,
          searchController: _searchController,
          onSearchChanged: (value) {
            ref
                .read(searchResultProvider.notifier)
                .search(value); // 바로 debounce 실행
          }),
      body: resultState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("검색 중 오류 발생: $err")),
        data: (results) {
          if (results.isEmpty) {
            return const Center(child: Text("검색 결과가 없습니다."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final funding = results[index];
              return GestureDetector(
                onTap: () {
                  context.push('/funding/detail', extra: funding);
                },
                child: FundingCard(funding: funding),
              );
            },
          );
        },
      ),
    );
  }
}

// 필터용 카테고리 칩
class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color(0xFFF1F1F1),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}

// 인기 검색어 아이템
class _PopularKeyword extends StatelessWidget {
  final int rank;
  final String keyword;

  const _PopularKeyword({required this.rank, required this.keyword});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$rank ',
              style: const TextStyle(
                  color: Colors.green, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: keyword,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
