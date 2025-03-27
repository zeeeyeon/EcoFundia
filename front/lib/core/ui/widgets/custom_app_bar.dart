import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showHomeButton;
  final bool showSearchField;
  final bool showSearchIcon;
  final bool isSearchEnabled; // 검색창 입력 활성화 여부 추가
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchTap;
  final VoidCallback? onSearchSubmit;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.showHomeButton = false,
    this.showSearchField = false,
    this.showSearchIcon = false,
    this.isSearchEnabled = false, // 기본값 false
    this.searchController,
    this.onSearchChanged,
    this.onSearchTap,
    this.onSearchSubmit,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // 기본 간격 제거
      leadingWidth: 30, // 🔙 아이콘과 검색창 간격 줄이기
      title: showSearchField
          ? isSearchEnabled
              ? _buildSearchField() // 입력 가능
              : GestureDetector(
                  onTap: onSearchTap,
                  child: AbsorbPointer(
                      child: _buildSearchField()), // 입력 불가 (탭만 가능)
                )
          : (title != null
              ? Text(
                  title!,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                )
              : null),
      centerTitle: true,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: [
        if (actions != null) ...actions!,
        if (showHomeButton)
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              context.go('/');
            },
          ),
      ],
    );
  }

  // 검색 필드 빌더 (공통으로 사용)
  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchTap,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.lightGreen),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
