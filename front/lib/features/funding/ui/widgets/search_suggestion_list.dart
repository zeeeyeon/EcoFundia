import 'package:flutter/material.dart';

class SearchSuggestionList extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String keyword) onTap;

  const SearchSuggestionList({
    super.key,
    required this.suggestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxHeight = constraints.maxHeight * 0.4;

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: 50,
            maxHeight: maxHeight.clamp(150, 300),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            itemCount: suggestions.length,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final keyword = suggestions[index];

              return _SuggestionItem(
                keyword: keyword,
                onTap: () => onTap(keyword),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
          ),
        );
      },
    );
  }
}

class _SuggestionItem extends StatefulWidget {
  final String keyword;
  final VoidCallback onTap;

  const _SuggestionItem({
    required this.keyword,
    required this.onTap,
  });

  @override
  State<_SuggestionItem> createState() => _SuggestionItemState();
}

class _SuggestionItemState extends State<_SuggestionItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isHovered = true),
        onTapUp: (_) => setState(() => isHovered = false),
        onTapCancel: () => setState(() => isHovered = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isHovered ? Colors.grey.shade100 : Colors.transparent,
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.keyword,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                    letterSpacing: 0.2,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
