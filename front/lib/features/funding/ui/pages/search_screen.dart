import 'dart:async'; // ✅ debounce용 Timer 추가

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/ui/widgets/custom_app_bar.dart';
import 'package:front/features/funding/ui/view_model/search_view_model.dart';
import 'package:front/features/funding/ui/view_model/search_special_view_model.dart';
import 'package:front/features/funding/ui/widgets/funding_card.dart';
import 'package:front/features/funding/data/models/funding_model.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/features/funding/ui/view_model/search_suggest_view_model.dart'; // ✅ 자동완성 ViewModel
import 'package:front/features/funding/ui/widgets/search_suggestion_list.dart'; // ✅ 자동완성 리스트 위젯

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedTopic;
  Timer? _debounce; // ✅ debounce 타이머 추가

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
    _debounce?.cancel(); // ✅ debounce 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specialState = _selectedTopic != null
        ? ref.watch(specialFundingProvider(_selectedTopic!))
        : null;
    final resultState = ref.watch(searchResultProvider);
    final isFetchingSpecial = _selectedTopic != null
        ? ref.watch(specialFundingProvider(_selectedTopic!).notifier).isFetching
        : false;
    final isFetchingSearch =
        ref.watch(searchResultProvider.notifier).isFetching;

    final bool isFetchingMore = isFetchingSpecial || isFetchingSearch;
    final suggestions = ref.watch(searchSuggestProvider); // ✅ 자동완성 state

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        showBackButton: true,
        showSearchField: true,
        isSearchEnabled: true,
        searchController: _searchController,
        onSearchChanged: (value) {
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 300), () {
            ref.read(searchSuggestProvider.notifier).fetch(value);
            ref
                .read(searchResultProvider.notifier)
                .search(value); // ✅ 기존 검색도 유지
          });
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // ✅ 자동완성 리스트 추가
          if (suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchSuggestionList(
                suggestions: suggestions,
                onTap: (selected) {
                  _searchController.text = selected;
                  ref.read(searchResultProvider.notifier).search(selected);
                  ref.read(searchSuggestProvider.notifier).clear();
                  FocusScope.of(context).unfocus(); // 키보드 내리기
                },
              ),
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildSearchChip("⭐ 베스트펀딩", "best"),
                _buildSearchChip("⏰ 마감임박", "soon"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedTopic != null
                ? specialState!.when(
                    loading: () => specialState.hasValue &&
                            specialState.value!.isNotEmpty
                        ? _buildSearchResults(
                            specialState.value!, isFetchingMore)
                        : const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary)),
                    error: (err, _) => Center(child: Text("검색 오류: $err")),
                    data: (results) {
                      if (results.isEmpty && !isFetchingMore) {
                        return const Center(
                            child: Text(SearchStrings.noResults));
                      }
                      return _buildSearchResults(results, isFetchingMore);
                    })
                : resultState.when(
                    loading: () =>
                        resultState.hasValue && resultState.value!.isNotEmpty
                            ? _buildSearchResults(
                                resultState.value!, isFetchingMore)
                            : const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.primary)),
                    error: (err, _) => Center(child: Text("에러 발생: $err")),
                    data: (results) {
                      if (results.isEmpty && !isFetchingMore) {
                        return const Center(
                            child: Text(SearchStrings.noResults));
                      }
                      return _buildSearchResults(results, isFetchingMore);
                    }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String label, String topicKey) {
    final isSelected = _selectedTopic == topicKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTopic = isSelected ? null : topicKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.extraLightGrey,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? AppColors.white : AppColors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(
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
              LoggerUtil.d('펀딩 검색 결과 클릭: ${funding.fundingId}');
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
