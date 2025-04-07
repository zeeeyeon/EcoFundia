import 'package:equatable/equatable.dart';

/// 판매자 정보를 표현하는 엔티티 클래스
class SellerEntity extends Equatable {
  final int id;
  final String name;
  final String? profileImageUrl;
  final bool isMaker; // 예: 킹 메이커
  final bool isTop100;
  final double satisfaction; // 만족도 점수 (예: 4.5)
  final int reviewCount; // 리뷰 개수
  final String totalFundingAmount; // 누적 액수 (예: '5,500만원+')
  final int likeCount; // 좋아요 수

  const SellerEntity({
    required this.id,
    required this.name,
    this.profileImageUrl,
    required this.isMaker,
    required this.isTop100,
    required this.satisfaction,
    required this.reviewCount,
    required this.totalFundingAmount,
    required this.likeCount,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        profileImageUrl,
        isMaker,
        isTop100,
        satisfaction,
        reviewCount,
        totalFundingAmount,
        likeCount,
      ];
}
