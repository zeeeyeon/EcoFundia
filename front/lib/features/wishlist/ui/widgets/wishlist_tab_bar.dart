import 'package:flutter/material.dart';

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
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 진행 중 탭
          _buildTabItem(
            context: context,
            index: 0,
            title: '진행중',
          ),
          const SizedBox(width: 5),
          // 종료된 탭
          _buildTabItem(
            context: context,
            index: 1,
            title: '종료된 펀딩',
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
          horizontal: 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFA3D80D) : Colors.transparent,
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
