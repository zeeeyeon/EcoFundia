import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/themes/app_shadows.dart';
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
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];

              return InkWell(
                onTap: () {
                  context.push('/project/${review.fundingId}');
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [AppShadows.card],
                    border:
                        Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.title,
                        style: AppTextStyles.itemTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                Icons.star,
                                size: 18,
                                color: i < review.rating
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            review.nickname,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        review.content,
                        style: AppTextStyles.body2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              context.push(
                                '/mypage/review/edit/${review.reviewId}',
                                extra: {
                                  'initialRating': review.rating,
                                  'initialContent': review.content,
                                  'title': review.title,
                                  'description': review.description,
                                  'totalPrice': review.totalPrice,
                                },
                              );
                            },
                            child: const Text('수정',
                                style: TextStyle(fontSize: 13)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('리뷰 삭제'),
                                  content: const Text('정말 이 리뷰를 삭제하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, false),
                                      child: const Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, true),
                                      child: const Text('삭제',
                                          style: TextStyle(color: Colors.red)),
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('리뷰가 삭제되었습니다.')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('삭제 실패: $e')),
                                    );
                                  }
                                }
                              }
                            },
                            child: const Text('삭제'),
                          ),
                        ],
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
