import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/view_model/funding_list_view_model.dart'; // ✅ selectedCategoriesProvider 위치

// UI 텍스트 → API 값 매핑
const categoryMap = {
  '푸드': 'FOOD',
  '패션/잡화': 'FASHION',
  '생필품': 'HOUSEHOLD',
  '전자/가전': 'ELECTRONICS',
  '가구/인테리어': 'INTERIOR',
};

class CategoryFilterWidget extends ConsumerWidget {
  const CategoryFilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoriesProvider);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categoryMap.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final uiText = categoryMap.keys.elementAt(index);
          final apiValue = categoryMap[uiText]!;
          final isSelected = selected.contains(apiValue);

          return GestureDetector(
            onTap: () {
              final notifier = ref.read(fundingListProvider.notifier);
              final currentSelected =
                  ref.read(selectedCategoriesProvider).toList();
              final apiValue = categoryMap[uiText]!;

              // 선택 해제 or 추가
              if (currentSelected.contains(apiValue)) {
                currentSelected.remove(apiValue);
              } else {
                currentSelected.add(apiValue);
              }

              // 업데이트
              ref.read(selectedCategoriesProvider.notifier).state =
                  currentSelected;

              // 정렬 옵션도 같이 읽어와서 전달
              final sort = ref.read(sortOptionProvider);

              notifier.fetchFundingList(
                page: 1,
                sort: sort,
                categories: currentSelected,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                uiText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
