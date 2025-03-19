import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: true, // 제목을 중앙 정렬
      elevation: 0, // 그림자 제거 (디자인에 따라 조정 가능)
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(), // 뒤로 가기 버튼
            )
          : null, // 뒤로 가기 버튼을 보이지 않도록 설정 가능
      actions: actions, // 우측 아이콘 추가 가능
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
