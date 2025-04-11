import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';

class MyFundingTabBar extends StatelessWidget {
  final TabController tabController;

  const MyFundingTabBar({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        children: [
          // 진행 중 탭
          Expanded(
            child: _buildTabItem(
              context: context,
              index: 0,
              title: '진행중+',
            ),
          ),
          const SizedBox(width: 5),
          // 종료된 펀딩 탭
          Expanded(
            child: _buildTabItem(
              context: context,
              index: 1,
              title: '마감',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required int index,
    required String title,
  }) {
    final isSelected = tabController.index == index;

    return GestureDetector(
      onTap: () => tabController.animateTo(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
