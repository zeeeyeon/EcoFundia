import 'package:flutter/material.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';

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
        // 화면 크기에 따른 동적 값 설정
        final screenSize = MediaQuery.of(context).size;
        final isSmallScreen = screenSize.width < 360; // 작은 화면 기준

        // 동적으로 폰트 크기 조정
        final titleFontSize = isSmallScreen ? 14.0 : screenSize.width * 0.045;
        final descFontSize = isSmallScreen ? 12.0 : screenSize.width * 0.035;
        final priceFontSize = isSmallScreen ? 11.0 : screenSize.width * 0.035;
        final buttonFontSize = isSmallScreen ? 11.0 : screenSize.width * 0.035;

        // 동적으로 패딩 조정
        final cardPadding = isSmallScreen ? 8.0 : screenSize.width * 0.04;

        return Container(
          width: constraints.maxWidth,
          constraints: BoxConstraints(
            // 최대 높이는 유지하되, 비율로 설정
            maxHeight: screenSize.height * 0.55,
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
          // FittedBox으로 감싸서 내용이 작은 화면에 맞게 축소되도록 함
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 이미지는 화면 크기에 따라 동적으로 비율 조정
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: AspectRatio(
                  // 작은 화면에서는 이미지 비율을 줄임
                  aspectRatio: isSmallScreen ? 16 / 10 : 16 / 12,
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
              // Flexible로 내용 부분이 화면 크기에 맞게 조정되도록 함
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: HomeTextStyles.projectTitle.copyWith(
                          fontSize: titleFontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                          height: isSmallScreen ? 4 : screenSize.height * 0.01),
                      Text(
                        AppStrings.introduction,
                        style: HomeTextStyles.projectLabel.copyWith(
                          fontSize: descFontSize,
                        ),
                      ),
                      // Flexible로 감싸서 설명 텍스트가 남은 공간에 맞게 조정되도록 함
                      Flexible(
                        child: Text(
                          description,
                          style: HomeTextStyles.projectDescription.copyWith(
                            fontSize: descFontSize,
                          ),
                          maxLines: isSmallScreen ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                          height: isSmallScreen ? 8 : screenSize.height * 0.02),
                      // 하단 섹션
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 가격 정보
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$percentage %',
                                      style: HomeTextStyles.projectPercentage
                                          .copyWith(
                                        fontSize: isSmallScreen
                                            ? 12
                                            : screenSize.width * 0.04,
                                      ),
                                    ),
                                    SizedBox(
                                        width: isSmallScreen
                                            ? 4
                                            : screenSize.width * 0.02),
                                    Flexible(
                                      child: Text(
                                        price,
                                        style: HomeTextStyles.projectPrice
                                            .copyWith(
                                          fontSize: priceFontSize,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // 액션 버튼
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 좋아요 버튼을 작은 화면에서는 더 작게 표시
                              IconButton(
                                icon: Icon(
                                  Icons.favorite_border,
                                  size: isSmallScreen
                                      ? 20
                                      : screenSize.width * 0.06,
                                ),
                                onPressed: onLikeTap,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              SizedBox(
                                  width: isSmallScreen
                                      ? 4
                                      : screenSize.width * 0.01),
                              // 구매 버튼
                              ElevatedButton(
                                onPressed: onPurchaseTap,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen
                                        ? 8
                                        : screenSize.width * 0.04,
                                    vertical: isSmallScreen
                                        ? 4
                                        : screenSize.height * 0.01,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  AppStrings.purchase,
                                  style: TextStyle(
                                    fontSize: buttonFontSize,
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
