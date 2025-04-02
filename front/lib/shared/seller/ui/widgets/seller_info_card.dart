import 'package:flutter/material.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/shared/seller/domain/entities/seller_entity.dart';

/// 판매자 정보 카드 위젯
class SellerInfoCard extends StatelessWidget {
  final SellerEntity seller;

  const SellerInfoCard({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
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
          _buildSellerHeader(),
          const SizedBox(height: 20),
          _buildSellerStats(),
        ],
      ),
    );
  }

  /// 판매자 헤더 정보 위젯
  Widget _buildSellerHeader() {
    return Row(
      children: [
        // 프로필 이미지
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage: seller.profileImageUrl != null
              ? AssetImage(seller.profileImageUrl!)
              : const AssetImage('assets/images/apple.png'),
          child: seller.profileImageUrl == null
              ? const Icon(
                  Icons.store,
                  size: 30,
                  color: AppColors.primary,
                )
              : null,
        ),
        const SizedBox(width: 12),

        // 판매자 이름 및 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seller.name,
                style: SellerTextStyles.sellerName,
              ),
              const SizedBox(height: 8),
              Row(
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
                  if (seller.isTop100) const SizedBox(width: 8),
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
  Widget _buildSellerStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatItem(
          icon: Icons.star,
          title: '만족도',
          value: '${seller.satisfaction}',
          subtitle: '${seller.reviewCount}개 리뷰',
        ),
        _buildStatItem(
          icon: Icons.attach_money,
          title: '총 펀딩금액',
          value: seller.totalFundingAmount,
          subtitle: '',
        ),
        _buildStatItem(
          icon: Icons.favorite,
          title: '좋아요',
          value: '${seller.likeCount}',
          subtitle: '',
        ),
      ],
    );
  }

  /// 통계 아이템 위젯 (세로 정렬)
  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return SizedBox(
      width: 100, // 고정 너비 설정
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // 가운데 정렬
        children: [
          Icon(
            icon,
            size: 24,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: SellerTextStyles.statTitle,
            textAlign: TextAlign.center, // 텍스트 가운데 정렬
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: SellerTextStyles.statValue,
            textAlign: TextAlign.center, // 텍스트 가운데 정렬
          ),
          if (subtitle.isNotEmpty) const SizedBox(height: 2),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: SellerTextStyles.statDetail,
              textAlign: TextAlign.center, // 텍스트 가운데 정렬
            ),
        ],
      ),
    );
  }
}
