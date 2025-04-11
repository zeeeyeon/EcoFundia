import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
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

    final selectedDisplayText = sortOptions.entries
        .firstWhere((entry) => entry.value == selectedSort)
        .key;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedSort,
            onChanged: (newValue) {
              if (newValue != null) {
                ref.read(sortOptionProvider.notifier).state = newValue;
                ref.read(fundingListProvider.notifier).fetchFundingList(
                      page: 1,
                      sort: newValue,
                      categories: ref.read(selectedCategoriesProvider),
                    );
              }
            },
            selectedItemBuilder: (BuildContext context) {
              return sortOptions.keys.map<Widget>((String key) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    key,
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey,
                    ),
                  ),
                );
              }).toList();
            },
            icon: Transform.rotate(
              angle: 1.5708,
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: AppColors.grey,
              ),
            ),
            items: sortOptions.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.value,
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
