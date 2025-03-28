import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/ui/widgets/custom_app_bar.dart';
import 'package:front/features/funding/ui/widgets/search_category_chip.dart';
import 'package:front/features/funding/ui/widgets/search_funding_list.dart';
import 'package:front/features/funding/ui/view_model/search_view_model.dart';
import 'package:front/features/funding/ui/view_model/search_special_view_model.dart';

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
                SearchCategoryChip(
                  label: "⭐ 베스트펀딩",
                  isSelected: _selectedTopic == "best",
                  onTap: () => setState(() {
                    _selectedTopic = (_selectedTopic == "best") ? null : "best";
                  }),
                ),
                SearchCategoryChip(
                  label: "⏰ 마감임박",
                  isSelected: _selectedTopic == "soon",
                  onTap: () => setState(() {
                    _selectedTopic = (_selectedTopic == "soon") ? null : "soon";
                  }),
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
                    error: (err, _) => Center(child: Text("검색 오류: $err")),
                    data: (results) => SearchFundingList(
                      fundingList: results,
                      scrollController: _scrollController,
                      isFetching: ref
                          .read(
                              specialFundingProvider(_selectedTopic!).notifier)
                          .isFetching,
                    ),
                  )
                : resultState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text("에러 발생: $err")),
                    data: (results) => SearchFundingList(
                      fundingList: results,
                      scrollController: _scrollController,
                      isFetching:
                          ref.read(searchResultProvider.notifier).isFetching,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
