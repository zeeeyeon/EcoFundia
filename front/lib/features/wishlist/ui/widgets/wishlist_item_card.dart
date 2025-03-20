import 'package:flutter/material.dart';
import 'package:front/features/wishlist/domain/entities/wishlist_item_entity.dart';

/// 위시리스트 아이템 카드 위젯
/// 찜한 펀딩 프로젝트 정보를 카드 형태로 표시
class WishlistItemCard extends StatelessWidget {
  final WishlistItemEntity item;
  final Function(int) onToggleLike;
  final Function(int) onParticipate;

  const WishlistItemCard({
    super.key,
    required this.item,
    required this.onToggleLike,
    required this.onParticipate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(5),
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
                      child: Image.asset(
                        item.imageUrl,
                        width: 100,
                        height: 85,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // 좋아요 버튼
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: item.isLiked
                                ? Colors.red
                                : Colors.grey.shade300,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                          onPressed: () => onToggleLike(item.id),
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
                        item.companyName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // 제품명
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
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
                          color: const Color(0xFFA3D80D),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          item.remainingDays,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 펀딩 달성률 및 금액
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.fundingPercentage.toStringAsFixed(0)}% 달성',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.fundingAmount,
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                // 참여하기 버튼
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFA3D80D),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: InkWell(
                    onTap: () => onParticipate(item.id),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      child: Text(
                        '참여하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
