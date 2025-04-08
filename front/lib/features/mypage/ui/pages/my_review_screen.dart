import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import 'package:front/core/themes/app_colors.dart';
import '../view_model/my_review_view_model.dart';
import 'package:go_router/go_router.dart';

class MyReviewScreen extends ConsumerWidget {
  const MyReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewState = ref.watch(myReviewProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
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
                      // 리뷰 제목 + 수정/삭제 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              review.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  context.push(
                                    '/review/edit/${review.reviewId}',
                                    extra: {
                                      'rating': review.rating,
                                      'content': review.content,
                                      'title': review.title,
                                      'description': review.description,
                                      'totalPrice': review.totalPrice,
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('리뷰 삭제'),
                                      content: const Text('정말 이 리뷰를 삭제하시겠습니까?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                              dialogContext, false),
                                          child: const Text('취소'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                              dialogContext, true),
                                          child: const Text('삭제'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      await ref
                                          .read(myReviewProvider.notifier)
                                          .deleteReview(review.reviewId);

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('리뷰가 삭제되었습니다.')),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text('삭제 실패: $e')),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
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
