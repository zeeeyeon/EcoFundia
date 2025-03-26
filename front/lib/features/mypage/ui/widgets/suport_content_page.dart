import 'package:flutter/material.dart';
import 'package:front/core/ui/widgets/custom_app_bar.dart';

class SupportContentPage extends StatelessWidget {
  final String title;
  final List<String> paragraphs;

  const SupportContentPage({
    super.key,
    required this.title,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: title,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: paragraphs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  paragraphs[index],
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
