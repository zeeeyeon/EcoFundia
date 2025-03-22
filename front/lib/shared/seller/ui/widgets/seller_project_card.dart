import 'package:flutter/material.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/shared/seller/domain/entities/seller_project_entity.dart';
import 'package:front/utils/logger_util.dart';
import 'package:intl/intl.dart';

/// 판매자 프로젝트 카드 위젯
class SellerProjectCard extends StatelessWidget {
  final SellerProjectEntity project;
  final VoidCallback onTap;

  const SellerProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // 상단 제품 정보 영역
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제품 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: project.imageUrl.startsWith('http')
                        ? Image.network(
                            project.imageUrl,
                            width: 120,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              LoggerUtil.e('❌ 이미지 로드 실패', error);
                              return Container(
                                width: 120,
                                height: 100,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.grey,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            project.imageUrl,
                            width: 120,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              LoggerUtil.e('❌ 이미지 로드 실패', error);
                              return Container(
                                width: 120,
                                height: 100,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.grey,
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(width: 15),

                  // 제품 설명 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 회사명
                        Text(
                          project.companyName,
                          style: WishlistTextStyles.companyName,
                        ),
                        const SizedBox(height: 5),

                        // 제품명
                        Text(
                          project.title,
                          style: WishlistTextStyles.itemTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),

                        // 상태 표시
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: project.isActive
                                ? AppColors.primary
                                : AppColors.grey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            project.isActive ? project.remainingDays : '마감',
                            style: WishlistTextStyles.badge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 하단 펀딩 정보 영역
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color.fromARGB(255, 236, 234, 234)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // 펀딩 달성률
                  Text(
                    '${NumberFormat.decimalPattern().format(project.fundingPercentage.toInt())}% 달성',
                    style: WishlistTextStyles.fundingPercentage,
                  ),
                  const SizedBox(width: 10),

                  // 펀딩 금액
                  Text(
                    project.fundingAmount,
                    style: WishlistTextStyles.fundingAmount,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
