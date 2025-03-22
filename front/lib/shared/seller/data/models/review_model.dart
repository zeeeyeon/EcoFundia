import 'package:front/shared/seller/domain/entities/review_entity.dart';

/// 리뷰 API 응답 모델
class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.userName,
    required super.rating,
    required super.content,
    required super.productName,
    required super.createdAt,
  });

  /// API 응답 JSON을 ReviewModel로 변환
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      userName: json['user_name'],
      rating: (json['rating'] as num).toDouble(),
      content: json['content'],
      productName: json['product_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
