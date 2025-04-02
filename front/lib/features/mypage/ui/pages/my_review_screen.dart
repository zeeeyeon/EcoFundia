import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import '../view_model/my_review_view_model.dart';

class MyReviewScreen extends ConsumerWidget {
  const MyReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewState = ref.watch(myReviewProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: '내 리뷰',
        showBackButton: true,
      ),
      body: reviewState.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return const Center(child: Text('아직 작성한 리뷰가 없어요.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            Icons.star,
                            size: 18,
                            color: i < review.rating
                                ? Colors.green
                                : Colors.grey.shade300,
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review.content,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '작성자: ${review.nickname}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('에러 발생: $err')),
      ),
    );
  }
}
