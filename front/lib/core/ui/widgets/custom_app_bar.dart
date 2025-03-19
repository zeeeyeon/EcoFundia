import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showHomeButton;
  final bool showSearchField;
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchSubmit;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.title, // ✅ 타이틀이 없어도 가능
    this.showBackButton = false,
    this.showHomeButton = false,
    this.showSearchField = false, // 기본값: 검색 필드 비활성화
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmit,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: showSearchField
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: "펀딩 검색...",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      if (onSearchSubmit != null) {
                        onSearchSubmit!();
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.lightGreen),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
