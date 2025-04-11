import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/constants/app_sizes.dart';
import 'package:front/core/themes/app_shadows.dart';
import 'package:front/shared/seller/domain/entities/review_entity.dart';
import 'package:front/shared/widgets/star_rating.dart';

/// 리뷰 카드 위젯
class ReviewCard extends StatelessWidget {
  final ReviewEntity review;

  const ReviewCard({
    Key? key,
    required this.review,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusM),
        boxShadow: const [
          AppShadows.card,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 영역 - 사용자 이름과 별점
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.userName,
                style: SellerTextStyles.reviewUserName,
              ),
              StarRating(
                rating: review.rating,
                size: AppSizes.iconM,
                activeColor: AppColors.primary,
              ),
            ],
          ),

          // 리뷰 내용
          const SizedBox(height: AppSizes.spacingM),
          Text(
            review.content,
            style: SellerTextStyles.reviewContent,
          ),

          // 제품 정보
          const SizedBox(height: AppSizes.spacingM),
          Text(
            review.productName,
            style: SellerTextStyles.reviewProductName,
          ),
        ],
      ),
    );
  }
}
