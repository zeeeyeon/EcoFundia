import 'package:equatable/equatable.dart';

/// 위시리스트 아이템 엔티티
/// 도메인 레이어에서 사용되는 찜한 펀딩 프로젝트 기본 데이터 구조
class WishlistItemEntity extends Equatable {
  final int id;
  final String title;
  final String description;
  final String companyName;
  final String imageUrl;
  final double fundingPercentage;
  final String fundingAmount;
  final String remainingDays;
  final bool isActive; // 진행 중 여부
  final bool isLiked; // 좋아요 상태

  const WishlistItemEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.companyName,
    required this.imageUrl,
    required this.fundingPercentage,
    required this.fundingAmount,
    required this.remainingDays,
    required this.isActive,
    this.isLiked = true, // 위시리스트에 있으므로 기본값은 true
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        companyName,
        imageUrl,
        fundingPercentage,
        fundingAmount,
        remainingDays,
        isActive,
        isLiked,
      ];
}
