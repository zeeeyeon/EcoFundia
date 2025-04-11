import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ 리뷰 상태 가져오기 위해 추가
import 'package:go_router/go_router.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/features/mypage/data/models/my_funding_model.dart';
import 'package:intl/intl.dart';
import '../view_model/my_review_view_model.dart'; // ✅ 리뷰 리스트 Provider 접근을 위해 import
import 'package:cached_network_image/cached_network_image.dart';
import 'package:front/utils/funding_status.dart'; // ✅ FundingStatus import

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

    return InkWell(
      onTap: () {
        // 홈의 프로젝트 상세 페이지로 이동하도록 경로 수정
        context.push('/project/${funding.fundingId}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
              color: AppColors.lightGrey
                  .withOpacity(0.5)), // Match Wishlist border
          borderRadius: BorderRadius.circular(12), // Match Wishlist radius
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top section: Image and Basic Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: funding.imageUrls.isNotEmpty
                          ? funding.imageUrls.first
                          : '', // Provide a placeholder URL or handle empty list
                      width: 100, // Adjust size as needed
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey.shade200,
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported,
                            color: AppColors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          funding.title,
                          style: AppTextStyles.itemTitle, // Use AppTextStyles
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          funding.description,
                          style: AppTextStyles.body2
                              .copyWith(color: AppColors.grey, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                isActive ? AppColors.primary : AppColors.grey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            isActive ? 'D-$remainingDays' : '마감',
                            style: AppTextStyles.badge, // Use AppTextStyles
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom section: My Investment Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                    top: BorderSide(
                        color: AppColors.lightGrey.withOpacity(0.5))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('나의 후원금',
                      style: AppTextStyles.body2
                          .copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    '${NumberFormat.decimalPattern().format(funding.totalPrice)}원',
                    style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ),

            // ✅ 리뷰 버튼 추가 영역 시작
            if (!isOngoing(funding.status)) // 마감 상태인 경우에만 버튼 표시
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 12, top: 0), // 위쪽 패딩 제거
                child:
                    _buildReviewButton(context, ref, funding, alreadyReviewed),
              ),
            // ✅ 리뷰 버튼 추가 영역 끝
          ],
        ),
      ),
    );
  }

  // ✅ 리뷰 버튼 빌드 함수 추가
  Widget _buildReviewButton(
    BuildContext context,
    WidgetRef ref,
    MyFundingModel funding,
    bool alreadyReviewed,
  ) {
    final myReviewsAsync = ref.watch(myReviewProvider);

    return myReviewsAsync.maybeWhen(
      data: (reviews) {
        // fundingId로 해당 펀딩의 리뷰 찾기
        final review =
            reviews.where((r) => r.fundingId == funding.fundingId).firstOrNull;

        final bool hasReview = review != null;
        final String buttonText = hasReview ? '리뷰 수정' : '리뷰 쓰기';
        final IconData buttonIcon =
            hasReview ? Icons.edit_note : Icons.rate_review_outlined;

        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              final Map<String, dynamic> extra = {
                'title': funding.title,
                'description': funding.description,
                'totalPrice': funding.totalPrice,
              };

              if (hasReview) {
                // 리뷰 수정 화면으로 이동
                extra['initialRating'] = review.rating;
                extra['initialContent'] = review.content;
                context.push('/mypage/review/edit/${review.reviewId}',
                    extra: extra);
              } else {
                // 리뷰 작성 화면으로 이동
                context.push('/mypage/review/write/${funding.fundingId}',
                    extra: extra);
              }
            },
            icon: Icon(buttonIcon, size: 18, color: AppColors.primary),
            label: Text(
              buttonText,
              style: AppTextStyles.body2.copyWith(color: AppColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        );
      },
      // 로딩 중이거나 에러 발생 시 버튼을 표시하지 않음
      orElse: () => const SizedBox.shrink(),
    );
  }
}
