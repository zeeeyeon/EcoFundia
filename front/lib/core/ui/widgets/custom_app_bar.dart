import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/themes/app_colors.dart'; // Import AppColors

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
    List<Widget> leadingWidgets = [];
    if (showBackButton) {
      leadingWidgets.add(
        IconButton(
          padding: EdgeInsets.zero, // Reduce default padding
          constraints: const BoxConstraints(), // Remove constraints if needed
          icon: const Icon(Icons.arrow_back,
              color: AppColors.textDark), // Adjust color
          onPressed: () => Navigator.of(context).pop(),
        ),
      );
    }
    if (showHomeButton) {
      leadingWidgets.add(
        IconButton(
          padding: EdgeInsets.zero, // Reduce default padding
          constraints: const BoxConstraints(), // Remove constraints if needed
          icon:
              const Icon(Icons.home, color: AppColors.textDark), // Adjust color
          onPressed: () {
            context.go('/');
          },
        ),
      );
    }

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.white, // Set AppBar background to white
      surfaceTintColor: AppColors.white, // Prevent surface tinting effect
      elevation: 1, // Add a slight elevation/shadow
      shadowColor: AppColors.shadowColor.withOpacity(0.1),
      titleSpacing: 0, // Reduce default title spacing
      leading: leadingWidgets.isNotEmpty
          ? Padding(
              // Adjust padding around leading icons
              padding: const EdgeInsets.only(left: 8.0),
              child:
                  Row(mainAxisSize: MainAxisSize.min, children: leadingWidgets),
            )
          : null,
      title: showSearchField
          ? Padding(
              // Add padding to control spacing between leading icons and search field
              padding: EdgeInsets.only(
                  left: leadingWidgets.isNotEmpty ? 8.0 : 16.0, right: 16.0),
              child: isSearchEnabled
                  ? _buildSearchField()
                  : GestureDetector(
                      onTap: onSearchTap,
                      child: AbsorbPointer(child: _buildSearchField()),
                    ),
            )
          : (title != null
              ? Text(
                  title!,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark // Use textDark for title
                      ),
                )
              : null),
      centerTitle:
          !showSearchField, // Center title only if search field is not shown
      actions: actions, // Use provided actions directly
    );
  }

  Widget _buildSearchField() {
    const outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(25.0)),
      borderSide: BorderSide.none, // Remove default border
    );

    return SizedBox(
      height: 40, // Adjust height as needed
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        onSubmitted: (value) {
          // Trigger search on submit if needed
          if (onSearchSubmit != null) onSearchSubmit!();
        },
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: '검색어를 입력하세요...', // Add hint text
          hintStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppColors.grey, size: 20),
          // Use primary color for focused border
          focusedBorder: outlineInputBorder.copyWith(
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          // Use light grey for enabled (unfocused) border
          enabledBorder: outlineInputBorder.copyWith(
            borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
          ),
          border: outlineInputBorder, // Default border (can be same as enabled)
          filled: true,
          fillColor: AppColors.white, // Changed background to white
          isDense: true, // Reduce intrinsic padding
          contentPadding: EdgeInsets.zero, // Remove default content padding
        ),
        style: const TextStyle(
            fontSize: 14, color: AppColors.textDark), // Input text style
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
