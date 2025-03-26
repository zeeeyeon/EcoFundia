import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/view_model/funding_list_view_model.dart';

class SortDropdownWidget extends ConsumerWidget {
  const SortDropdownWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSort = ref.watch(sortOptionProvider);
    final sortOptions = {
      '최신순': 'latest',
      '오래된순': 'oldest',
      '인기순': 'popular',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButton<String>(
        value: selectedSort,
        onChanged: (newValue) {
          if (newValue != null) {
            ref.read(sortOptionProvider.notifier).state = newValue;

            // 정렬 변경 시 펀딩 리스트 새로 요청
            ref.read(fundingListProvider.notifier).fetchFundingList(
                  page: 1,
                  sort: newValue,
                  categories: ref.read(selectedCategoriesProvider),
                );
          }
        },
        icon: const Icon(Icons.keyboard_arrow_down),
        items: sortOptions.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.value,
            child: Text(entry.key),
          );
        }).toList(),
      ),
    );
  }
}
