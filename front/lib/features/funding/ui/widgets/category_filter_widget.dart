import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart'; // Import AppColors
import '../../ui/view_model/funding_list_view_model.dart'; // selectedCategoriesProvider 위치

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
      height: 36, // Figma height: 36px (based on frame height)
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categoryMap.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 12), // Figma gap: 12px
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
              // Figma padding: 9px 16px (selected), 9px 12px (unselected)
              // Using consistent padding for simplicity unless specified otherwise
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.extraLightGrey, // Changed to white
                borderRadius: BorderRadius.circular(32), // Figma: 32px
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors
                          .white, // Figma: #A3D80D / #F0F0F0 (Using lightGrey)
                  width: 1,
                ),
              ),
              child: Center(
                // Center text vertically
                child: Text(
                  uiText,
                  // Figma: Space Grotesk, 500, 12 (Selected, white assumed) / 400, 12 (Unselected, #979796)
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.grey, // Figma: White / #979796
                    letterSpacing: 0.005 * 12, // Figma: 0.5%
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
