import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';

/// 위시리스트 탭 바 위젯
/// '진행 중'과 '종료된' 탭을 표시
class WishlistTabBar extends StatelessWidget {
  final TabController tabController;

  const WishlistTabBar({
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
              title: '진행중',
            ),
          ),
          const SizedBox(width: 5),
          // 종료된 탭
          Expanded(
            child: _buildTabItem(
              context: context,
              index: 1,
              title: '종료된 펀딩',
            ),
          ),
        ],
      ),
    );
  }

  /// 탭 아이템 생성
  Widget _buildTabItem({
    required BuildContext context,
    required int index,
    required String title,
  }) {
    // 현재 선택된 탭인지 확인
    final isSelected = tabController.index == index;

    return GestureDetector(
      onTap: () => tabController.animateTo(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 50,
          vertical: 10,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.transparent,
          border: Border.all(
            color: AppColors.border,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textMuted,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
