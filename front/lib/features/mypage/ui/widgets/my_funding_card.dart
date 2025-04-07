import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ 리뷰 상태 가져오기 위해 추가
import 'package:front/utils/funding_status.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/features/mypage/data/models/my_funding_model.dart';
import 'package:front/utils/status_helper.dart';
import 'package:intl/intl.dart';
import '../view_model/my_review_view_model.dart'; // ✅ 리뷰 리스트 Provider 접근을 위해 import

class MyFundingCard extends ConsumerWidget {
  // ✅ Stateless → ConsumerWidget으로 변경
  final MyFundingModel funding;

  const MyFundingCard({Key? key, required this.funding}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ WidgetRef 추가
    final myReviews = ref.watch(myReviewProvider); // ✅ 리뷰 목록 상태

    final alreadyReviewed = myReviews.maybeWhen(
      data: (reviews) => reviews.any((r) => r.fundingId == funding.fundingId),
      orElse: () => false,
    );

    final remainingDays = funding.endDate.difference(DateTime.now()).inDays;
    final isActive = remainingDays > 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // 상단 영역: 이미지 + 설명
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    funding.imageUrls.first,
                    width: 120,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 90,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 15),
                // 텍스트 설명
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        funding.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        funding.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.grey,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          isActive ? 'D-$remainingDays' : '마감',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 하단 영역 전체 Column으로 변경
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color.fromARGB(255, 236, 234, 234)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 달성률 & 후원금
                Text(
                  '${funding.rate}% 달성',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '내 후원금: ${NumberFormat.decimalPattern().format(funding.totalPrice)}원',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),

                // 상태 텍스트 (우측 정렬)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    getStatusLabel(funding.status),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),

                // 리뷰 작성 or 수정 버튼 (status == SUCCESS)
                if (funding.status == FundingStatus.success) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFE0E0E0)),
                  const SizedBox(height: 12),
                  Text(
                    alreadyReviewed
                        ? '이 펀딩에 이미 후기를 남기셨어요.\n수정하시겠어요?'
                        : '이 펀딩은 종료되었어요!\n후기를 남겨보시는 건 어떨까요?',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        if (alreadyReviewed) {
                          final review = myReviews.asData!.value.firstWhere(
                              (r) => r.fundingId == funding.fundingId);

                          context.push(
                            '/review/edit/${review.reviewId}',
                            extra: {
                              'rating': review.rating,
                              'content': review.content,
                              'title': funding.title,
                              'description': funding.description,
                              'totalPrice': funding.totalPrice,
                            },
                          );
                        } else {
                          context.push(
                            '/review/${funding.fundingId}',
                            extra: {
                              'title': funding.title,
                              'description': funding.description,
                              'totalPrice': funding.totalPrice,
                            },
                          );
                        }
                      },
                      icon: Icon(
                        alreadyReviewed ? Icons.edit : Icons.rate_review,
                        size: 18,
                      ),
                      label: Text(
                        alreadyReviewed ? '리뷰 수정' : '리뷰 작성',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
