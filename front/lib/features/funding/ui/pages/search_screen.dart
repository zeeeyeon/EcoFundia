import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/ui/widgets/custom_app_bar.dart';
import 'package:front/features/funding/data/models/funding_model.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/funding/ui/view_model/search_view_model.dart';
import 'package:front/features/funding/ui/view_model/search_special_view_model.dart';
import 'package:front/features/funding/ui/widgets/funding_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedTopic;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_scrollController.position.outOfRange) {
        if (_selectedTopic != null) {
          final specialVM =
              ref.read(specialFundingProvider(_selectedTopic!).notifier);
          if (!specialVM.isFetching && specialVM.hasMore) {
            specialVM.fetchNextPage();
          }
        } else {
          final searchVM = ref.read(searchResultProvider.notifier);
          if (!searchVM.isFetching && searchVM.hasMore) {
            searchVM.fetchNextPage();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specialState = _selectedTopic != null
        ? ref.watch(specialFundingProvider(_selectedTopic!))
        : null;
    final resultState = ref.watch(searchResultProvider);

    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        showSearchField: true,
        isSearchEnabled: true,
        searchController: _searchController,
        onSearchChanged: (value) {
          ref.read(searchResultProvider.notifier).search(value);
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                _CategoryChip(
                  label: "\ud83c\udf1f \ubca0\uc2a4\ud2b8\ud380\ub529",
                  isSelected: _selectedTopic == "best",
                  onTap: () => setState(() => _selectedTopic = "best"),
                ),
                _CategoryChip(
                  label: "\u23f0 \ub9c8\uac10\uc784\ubc00",
                  isSelected: _selectedTopic == "soon",
                  onTap: () => setState(() => _selectedTopic = "soon"),
                ),
                _CategoryChip(
                  label: "# \uc624\ub984\uc758 \uac80\uc0c9\uc5b4",
                  isSelected: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _selectedTopic != null
                ? specialState!.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) =>
                        Center(child: Text("\uc5d0\ub7ec \ubc1c\uc0dd: $err")),
                    data: (results) => _buildFundingList(results),
                  )
                : resultState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) =>
                        Center(child: Text("\uac80\uc0c9 \uc624\ub958: $err")),
                    data: (results) => _buildFundingList(results),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundingList(List<FundingModel> list) {
    if (list.isEmpty) {
      return const Center(child: Text("검색 결과가 없습니다."));
    }
    final isFetching =
        ref.read(searchResultProvider.notifier).isFetching; // 로딩 상태 읽기
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: list.length + (isFetching ? 1 : 0), // 로딩 인디케이터 추가
      itemBuilder: (context, index) {
        if (index < list.length) {
          final funding = list[index];
          return GestureDetector(
            onTap: () => context.push('/funding/detail', extra: funding),
            child: FundingCard(funding: funding),
          );
        } else {
          // 아래쪽 로딩 인디케이터
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.green.shade100,
      backgroundColor: const Color(0xFFF1F1F1),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
