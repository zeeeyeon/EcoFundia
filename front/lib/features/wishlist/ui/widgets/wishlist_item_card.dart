import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:front/utils/logger_util.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 위시리스트 아이템 카드 위젯
/// 찜한 펀딩 프로젝트 정보를 카드 형태로 표시
class WishlistItemCard extends StatelessWidget {
  final WishlistItemEntity item;
  final Function(int) onToggleLike;
  final Function(int) onParticipate;
  final Function(int)? onNavigateToDetail;

  const WishlistItemCard({
    super.key,
    required this.item,
    required this.onToggleLike,
    required this.onParticipate,
    this.onNavigateToDetail,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = item.remainingDays > 0;

    return InkWell(
      onTap: () {
        if (isActive && onNavigateToDetail != null) {
          onNavigateToDetail!(item.id);
        }
      },
      splashColor:
          isActive ? Theme.of(context).splashColor : Colors.transparent,
      highlightColor:
          isActive ? Theme.of(context).highlightColor : Colors.transparent,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.8,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              // 상단 제품 정보 영역
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제품 이미지 & 좋아요 버튼
                    Stack(
                      children: [
                        // 제품 이미지
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: item.imageUrl.isNotEmpty &&
                                  item.imageUrl !=
                                      "https://example.com/default_image.jpg"
                              ? CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  width: 200,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 200,
                                    height: 150,
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) {
                                    LoggerUtil.e('❌ 이미지 로드 실패: $url', error);
                                    return Image.asset(
                                      'assets/images/test01.png',
                                      width: 200,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 200,
                                          height: 150,
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.image_not_supported,
                                                    color: AppColors.grey,
                                                    size: 40),
                                                SizedBox(height: 5),
                                                Text('이미지를 불러올 수 없습니다',
                                                    style: TextStyle(
                                                      color: AppColors.grey,
                                                      fontSize: 12,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/images/test01.png',
                                  width: 200,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    LoggerUtil.e('❌ 기본 이미지 로드 실패', error);
                                    return Container(
                                      width: 200,
                                      height: 150,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                          Icons.image_not_supported,
                                          color: AppColors.grey),
                                    );
                                  },
                                ),
                        ),
                        // 좋아요 버튼
                        Positioned(
                          right: 3,
                          top: 3,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadowLight,
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    color: item.isLiked
                                        ? AppColors.wishlistLiked
                                        : AppColors.border,
                                    size: 18,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 30,
                                    minHeight: 30,
                                  ),
                                  onPressed: () => onToggleLike(item.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    // 제품 설명 영역
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 회사명
                          Text(
                            item.sellerName,
                            style: WishlistTextStyles.companyName,
                          ),
                          const SizedBox(height: 5),
                          // 제품명
                          Text(
                            item.title,
                            style: WishlistTextStyles.itemTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          // 남은 기간 표시
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: item.remainingDays > 0
                                  ? AppColors.primary
                                  : AppColors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              item.remainingDays > 0
                                  ? '${item.remainingDays}일 남음'
                                  : '마감',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(
                    top: BorderSide(color: Color.fromARGB(255, 236, 234, 234)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 펀딩 달성률 및 금액
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${NumberFormat.decimalPattern().format(item.rate.toInt())}% 달성',
                            style: WishlistTextStyles.fundingPercentage,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${NumberFormat.decimalPattern().format(item.amountGap)}원',
                            style: WishlistTextStyles.fundingAmount,
                          ),
                        ],
                      ),
                    ),
                    // 참여하기 버튼
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.remainingDays > 0
                            ? AppColors.primary
                            : AppColors.grey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: InkWell(
                        onTap: item.remainingDays > 0
                            ? () => onParticipate(item.id)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          child: Text(
                            item.remainingDays > 0 ? '참여하기' : '마감',
                            style: WishlistTextStyles.participateButton,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
