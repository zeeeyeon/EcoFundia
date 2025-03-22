import 'package:front/shared/seller/domain/entities/seller_entity.dart';
import 'package:front/shared/seller/domain/entities/seller_project_entity.dart';

/// 판매자 정보 API 응답 모델
class SellerModel extends SellerEntity {
  const SellerModel({
    required super.id,
    required super.name,
    required super.profileImageUrl,
    required super.isMaker,
    required super.isTop100,
    required super.satisfaction,
    required super.reviewCount,
    required super.totalFundingAmount,
    required super.likeCount,
  });

  /// API 응답 JSON을 SellerModel로 변환
  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'],
      name: json['name'],
      profileImageUrl: json['profile_image_url'],
      isMaker: json['is_maker'] ?? false,
      isTop100: json['is_top_100'] ?? false,
      satisfaction: (json['satisfaction'] as num).toDouble(),
      reviewCount: json['review_count'],
      totalFundingAmount: json['total_funding_amount'],
      likeCount: json['like_count'],
    );
  }
}

/// 판매자 프로젝트 API 응답 모델
class SellerProjectModel extends SellerProjectEntity {
  const SellerProjectModel({
    required super.id,
    required super.title,
    required super.companyName,
    required super.imageUrl,
    required super.fundingPercentage,
    required super.fundingAmount,
    required super.remainingDays,
    required super.isActive,
  });

  /// API 응답 JSON을 SellerProjectModel로 변환
  factory SellerProjectModel.fromJson(Map<String, dynamic> json) {
    return SellerProjectModel(
      id: json['id'],
      title: json['title'],
      companyName: json['company_name'],
      imageUrl: json['image_url'],
      fundingPercentage: (json['funding_percentage'] as num).toDouble(),
      fundingAmount: json['funding_amount'],
      remainingDays: json['remaining_days'],
      isActive: json['is_active'] ?? true,
    );
  }
}
