import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/constants/app_sizes.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/shared/seller/domain/entities/review_entity.dart';
import 'package:front/shared/seller/ui/widgets/review_card.dart';
import 'package:front/shared/widgets/star_rating.dart';

/// 리뷰 탭 컨텐츠 위젯
class ReviewsTab extends StatelessWidget {
  final List<ReviewEntity> reviews;
  final double averageRating;
  final int totalReviews;

  const ReviewsTab({
    Key? key,
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 리뷰 상단 통계 영역
          _buildReviewStats(),

          // 구분선
          const Divider(height: 32.0, thickness: 1.0),

          // 리뷰 목록
          Expanded(
            child: reviews.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.emptyReviews,
                      style: AppTextStyles.emptyMessage,
                    ),
                  )
                : _buildReviewList(),
          ),
        ],
      ),
    );
  }

  /// 리뷰 통계 섹션
  Widget _buildReviewStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.reviewCount} $totalReviews개',
            style: SellerTextStyles.reviewHeader,
          ),
          const SizedBox(height: AppSizes.spacingL),

          // 평균 별점
          Center(
            child: Column(
              children: [
                Text(
                  '${averageRating.toStringAsFixed(1)}${AppStrings.point}',
                  style: SellerTextStyles.reviewStats,
                ),
                const SizedBox(height: AppSizes.spacingM),
                StarRating(
                  rating: averageRating,
                  size: AppSizes.iconL,
                  activeColor: AppColors.primary,
                  alignment: MainAxisAlignment.center,
                  spacing: 4.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 리뷰 목록
  Widget _buildReviewList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        return ReviewCard(review: reviews[index]);
      },
    );
  }
}
