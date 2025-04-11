import 'package:equatable/equatable.dart';

/// 위시리스트 아이템 엔티티
/// 도메인 레이어에서 사용되는 찜한 펀딩 프로젝트 기본 데이터 구조
class WishlistItemEntity extends Equatable {
  final int id; // fundingId
  final String title; // title
  final String imageUrl; // imageUrl
  final double rate; // rate (펀딩 달성률)
  final int remainingDays; // remainingDays
  final int amountGap; // amountGap (목표 금액까지 남은 금액)
  final String sellerName; // sellerName
  final bool isLiked; // 위시리스트에 있으므로 기본값은 true

  const WishlistItemEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.rate,
    required this.remainingDays,
    required this.amountGap,
    required this.sellerName,
    this.isLiked = true, // 위시리스트에 있으므로 기본값은 true
  });

  @override
  List<Object?> get props => [
        id,
        title,
        imageUrl,
        rate,
        remainingDays,
        amountGap,
        sellerName,
        isLiked,
      ];

  /// 필드 값 변경된 복사본 생성
  WishlistItemEntity copyWith({
    int? id,
    String? title,
    String? imageUrl,
    double? rate,
    int? remainingDays,
    int? amountGap,
    String? sellerName,
    bool? isLiked,
  }) {
    return WishlistItemEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      rate: rate ?? this.rate,
      remainingDays: remainingDays ?? this.remainingDays,
      amountGap: amountGap ?? this.amountGap,
      sellerName: sellerName ?? this.sellerName,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
