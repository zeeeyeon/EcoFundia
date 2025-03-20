import 'package:front/features/wishlist/domain/entities/wishlist_item_entity.dart';

/// 위시리스트 아이템 모델
/// API 데이터와 엔티티 간의 변환을 담당하는 모델 클래스
class WishlistItemModel extends WishlistItemEntity {
  const WishlistItemModel({
    required int id,
    required String title,
    required String description,
    required String companyName,
    required String imageUrl,
    required double fundingPercentage,
    required String fundingAmount,
    required String remainingDays,
    required bool isActive,
    bool isLiked = true,
  }) : super(
          id: id,
          title: title,
          description: description,
          companyName: companyName,
          imageUrl: imageUrl,
          fundingPercentage: fundingPercentage,
          fundingAmount: fundingAmount,
          remainingDays: remainingDays,
          isActive: isActive,
          isLiked: isLiked,
        );

  /// API JSON 응답으로부터 모델 객체 생성
  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      companyName: json['companyName'] as String,
      imageUrl: json['imageUrl'] as String,
      fundingPercentage: (json['fundingPercentage'] as num).toDouble(),
      fundingAmount: json['fundingAmount'] as String,
      remainingDays: json['remainingDays'] as String,
      isActive: json['isActive'] as bool,
      isLiked: json['isLiked'] as bool? ?? true,
    );
  }

  /// 모델 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'companyName': companyName,
      'imageUrl': imageUrl,
      'fundingPercentage': fundingPercentage,
      'fundingAmount': fundingAmount,
      'remainingDays': remainingDays,
      'isActive': isActive,
      'isLiked': isLiked,
    };
  }
}
