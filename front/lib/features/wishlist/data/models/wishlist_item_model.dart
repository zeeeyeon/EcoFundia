import 'package:front/features/wishlist/domain/entities/wishlist_item_entity.dart';

/// 위시리스트 아이템 모델
/// API 데이터와 엔티티 간의 변환을 담당하는 모델 클래스
class WishlistItemModel extends WishlistItemEntity {
  const WishlistItemModel({
    required int id,
    required String title,
    required String imageUrl,
    required double rate,
    required int remainingDays,
    required int amountGap,
    required String sellerName,
    bool isLiked = true,
  }) : super(
          id: id,
          title: title,
          imageUrl: imageUrl,
          rate: rate,
          remainingDays: remainingDays,
          amountGap: amountGap,
          sellerName: sellerName,
          isLiked: isLiked,
        );

  /// API JSON 응답으로부터 모델 객체 생성
  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['fundingId'] as int,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      rate: (json['rate'] as num).toDouble(),
      remainingDays: json['remainingDays'] as int,
      amountGap: json['amountGap'] as int,
      sellerName: json['sellerName'] as String,
      isLiked: true, // 위시리스트 목록이므로 항상 true
    );
  }

  /// 모델 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'fundingId': id,
      'title': title,
      'imageUrl': imageUrl,
      'rate': rate,
      'remainingDays': remainingDays,
      'amountGap': amountGap,
      'sellerName': sellerName,
    };
  }

  /// 복사본 생성
  @override
  WishlistItemModel copyWith({
    int? id,
    String? title,
    String? imageUrl,
    double? rate,
    int? remainingDays,
    int? amountGap,
    String? sellerName,
    bool? isLiked,
  }) {
    return WishlistItemModel(
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
