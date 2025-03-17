import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final double percentage;
  final String price;
  final String remainingTime;
  final VoidCallback onPurchaseTap;
  final VoidCallback onLikeTap;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.percentage,
    required this.price,
    required this.remainingTime,
    required this.onPurchaseTap,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth * 0.9;
        final screenSize = MediaQuery.of(context).size;

        return Container(
          width: cardWidth,
          constraints: BoxConstraints(
            maxHeight: screenSize.height * 0.50, // 전체 화면의 55% 제한
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: AspectRatio(
                  aspectRatio: 16 / 12,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.lightGrey.withOpacity(0.3),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported,
                                  size: 40, color: AppColors.grey),
                              SizedBox(height: 8),
                              Text(
                                '이미지를 불러올 수 없습니다',
                                style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(screenSize.width * 0.04),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.projectTitle.copyWith(
                          fontSize: screenSize.width * 0.045,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenSize.height * 0.01),
                      Text(
                        AppStrings.introduction,
                        style: AppTextStyles.projectLabel.copyWith(
                          fontSize: screenSize.width * 0.035,
                        ),
                      ),
                      Text(
                        description,
                        style: AppTextStyles.projectDescription.copyWith(
                          fontSize: screenSize.width * 0.035,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '$percentage %',
                                    style: AppTextStyles.projectPercentage
                                        .copyWith(
                                      fontSize: screenSize.width * 0.04,
                                    ),
                                  ),
                                  SizedBox(width: screenSize.width * 0.02),
                                  Text(
                                    price,
                                    style: AppTextStyles.projectPrice.copyWith(
                                      fontSize: screenSize.width * 0.035,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.favorite_border,
                                  size: screenSize.width * 0.06,
                                ),
                                onPressed: onLikeTap,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              SizedBox(width: screenSize.width * 0.01),
                              ElevatedButton(
                                onPressed: onPurchaseTap,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenSize.width * 0.04,
                                    vertical: screenSize.height * 0.01,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  AppStrings.purchase,
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.035,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
