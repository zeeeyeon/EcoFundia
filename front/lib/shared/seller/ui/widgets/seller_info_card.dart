import 'package:flutter/material.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/constants/app_sizes.dart';
import 'package:front/shared/seller/domain/entities/seller_entity.dart';
import 'package:front/utils/logger_util.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 판매자 정보 카드 위젯
class SellerInfoCard extends StatelessWidget {
  final SellerEntity seller;

  const SellerInfoCard({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSellerHeader(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          _buildSellerStats(context),
        ],
      ),
    );
  }

  /// 판매자 헤더 정보 위젯
  Widget _buildSellerHeader(BuildContext context) {
    // 디바이스 너비에 따른 동적 크기 계산
    final deviceWidth = MediaQuery.of(context).size.width;
    final avatarRadius = deviceWidth * 0.07; // 화면 너비에 비례하는 반응형 크기
    final horizontalSpacing = deviceWidth * 0.03;

    // 프로필 이미지 로직 개선 - S3 URL 등 다양한 형식 지원
    bool hasValidImageUrl = false;
    if (seller.profileImageUrl != null && seller.profileImageUrl!.isNotEmpty) {
      // S3, http, https 등 다양한 URL 패턴 지원
      hasValidImageUrl = seller.profileImageUrl!.startsWith('http') ||
          seller.profileImageUrl!.contains('s3.') ||
          seller.profileImageUrl!.contains('amazonaws.com');
    }

    LoggerUtil.d(
        '판매자 프로필 이미지 분석: URL=${seller.profileImageUrl}, 유효성=$hasValidImageUrl');

    return Row(
      children: [
        // 프로필 이미지 - CachedNetworkImage로 교체하여 성능 개선
        if (hasValidImageUrl)
          CachedNetworkImage(
            imageUrl: seller.profileImageUrl!,
            imageBuilder: (context, imageProvider) {
              LoggerUtil.d('이미지 로드 성공: ${seller.profileImageUrl}');
              return CircleAvatar(
                radius: avatarRadius,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: imageProvider,
              );
            },
            placeholder: (context, url) {
              LoggerUtil.d('이미지 로딩 중: $url');
              return CircleAvatar(
                radius: avatarRadius,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const CircularProgressIndicator(),
              );
            },
            errorWidget: (context, url, error) {
              LoggerUtil.e('이미지 로드 실패: $url, 오류: $error');
              return CircleAvatar(
                radius: avatarRadius,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(
                  Icons.store,
                  color: AppColors.primary,
                ),
              );
            },
          )
        else
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              Icons.store,
              color: AppColors.primary,
            ),
          ),
        SizedBox(width: horizontalSpacing),

        // 판매자 이름 및 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seller.name,
                style: SellerTextStyles.sellerName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Wrap(
                spacing: 8, // 가로 간격
                runSpacing: 8, // 세로 간격
                children: [
                  // 메이커 타입 뱃지
                  if (seller.isMaker)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '킹 메이커',
                        style: SellerTextStyles.badge,
                      ),
                    ),
                  if (seller.isTop100)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'TOP 100',
                        style: SellerTextStyles.badge,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 판매자 통계 정보 위젯 (세로 정렬)
  Widget _buildSellerStats(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // 화면 크기에 관계없이 항상 균등한 여백을 유지하도록 수정
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildStatItem(
                context: context,
                icon: Icons.star,
                title: '만족도',
                value: '${seller.satisfaction}',
                subtitle: '${seller.reviewCount}개 리뷰',
              ),
            ),
            const SizedBox(width: AppSizes.spacingM), // 고정 간격 추가
            Expanded(
              child: _buildStatItem(
                context: context,
                icon: Icons.attach_money,
                title: '총 펀딩금액',
                value:
                    '${NumberFormat.decimalPattern().format(int.parse(seller.totalFundingAmount))}원',
                subtitle: '',
              ),
            ),
            const SizedBox(width: AppSizes.spacingM), // 고정 간격 추가
            Expanded(
              child: _buildStatItem(
                context: context,
                icon: Icons.favorite,
                title: '좋아요',
                value: '${seller.likeCount}',
                subtitle: '',
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 통계 아이템 위젯 (세로 정렬)
  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final iconSize = deviceWidth * 0.06; // 반응형 아이콘 크기

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: iconSize < 16 ? 16 : (iconSize > 24 ? 24 : iconSize),
          color: AppColors.primary,
        ),
        const SizedBox(height: AppSizes.spacingS),
        Text(
          title,
          style: SellerTextStyles.statTitle,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: AppSizes.spacingXS),
        Text(
          value,
          style: SellerTextStyles.statValue,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        if (subtitle.isNotEmpty) const SizedBox(height: 2),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: SellerTextStyles.statDetail,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
      ],
    );
  }
}
