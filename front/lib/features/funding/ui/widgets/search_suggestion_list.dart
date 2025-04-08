import 'package:flutter/material.dart';

class SearchSuggestionList extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String) onTap;

  const SearchSuggestionList({
    super.key,
    required this.suggestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            title: Text(suggestion),
            onTap: () => onTap(suggestion),
          );
        },
      ),
    );
  }
}
