import 'package:front/shared/seller/domain/entities/seller_entity.dart';
import 'package:front/shared/seller/domain/entities/seller_project_entity.dart';
import 'package:front/utils/logger_util.dart';

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
    try {
      LoggerUtil.d('SellerModel.fromJson 변환 시작: $json');

      // 새로운 API 응답 구조에 맞게 필드 맵핑 (API 명세서 오타 처리 포함)
      final id = json['id'] ?? json['sellerId'] ?? json['sellerld'] ?? 0;
      final name = json['name'] ?? json['sellerName'] ?? '이름 없음';

      // 프로필 이미지 URL 처리 (API 명세서 오타 처리 포함)
      String? profileImageUrl = json['profileImageUrl'] ??
          json['sellerProfileImageUrl'] ??
          json['sellerProfilelmageUrl'];

      // URL이 유효한지 확인 (http로 시작하는지)
      if (profileImageUrl != null && !profileImageUrl.startsWith('http')) {
        LoggerUtil.w('유효하지 않은 이미지 URL 형식: $profileImageUrl');
        // 유효하지 않은 URL이면 null로 설정
        profileImageUrl = null;
      }

      // 새로운 API 필드 매핑
      final satisfaction = ((json['satisfaction'] ??
              json['rate'] ??
              json['rating'] ??
              json['totalRating'] ??
              0) as num)
          .toDouble();

      final reviewCount = json['reviewCount'] ??
          json['review_count'] ??
          json['ratingCount'] ??
          0;

      // totalAmount가 숫자일 경우 문자열로 변환
      final dynamic rawAmount = json['totalFundingAmount'] ??
          json['total_funding_amount'] ??
          json['amount'] ??
          json['totalAmount'] ??
          0;

      String totalFundingAmount;
      if (rawAmount is num) {
        totalFundingAmount = rawAmount.toString();
      } else {
        totalFundingAmount = rawAmount.toString();
      }

      final likeCount =
          json['likeCount'] ?? json['like_count'] ?? json['wishlistCount'] ?? 0;

      // API에서 제공하지 않는 필드는 기본값 사용
      final isMaker = json['isMaker'] ?? json['is_maker'] ?? false;
      final isTop100 = json['isTop100'] ?? json['is_top_100'] ?? false;

      LoggerUtil.d(
          'SellerModel.fromJson 변환 완료: {id: $id, name: $name, profileImageUrl: $profileImageUrl}');

      return SellerModel(
        id: id,
        name: name,
        profileImageUrl: profileImageUrl,
        isMaker: isMaker,
        isTop100: isTop100,
        satisfaction: satisfaction,
        reviewCount: reviewCount,
        totalFundingAmount: totalFundingAmount,
        likeCount: likeCount,
      );
    } catch (e) {
      LoggerUtil.e('SellerModel.fromJson 변환 오류', e);
      // 오류 발생 시 기본 값으로 객체 생성
      return const SellerModel(
        id: 0,
        name: '변환 오류',
        profileImageUrl: null,
        isMaker: false,
        isTop100: false,
        satisfaction: 0.0,
        reviewCount: 0,
        totalFundingAmount: '0',
        likeCount: 0,
      );
    }
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
    try {
      LoggerUtil.d('SellerProjectModel.fromJson 변환 시작');

      // 새로운 API 응답 구조에 맞게 필드 맵핑 (API 명세서 오타 처리 포함)
      final id = json['id'] ??
          json['fundingId'] ??
          json['fundingld'] ??
          json['projectId'] ??
          0;
      final title = json['title'] ?? '제목 없음';
      final companyName = json['companyName'] ??
          json['company_name'] ??
          json['sellerName'] ??
          '회사명 없음';

      // 이미지 URL 처리 (imageUrls 배열 또는 단일 URL)
      String imageUrl;
      if (json['imageUrls'] != null &&
          json['imageUrls'] is List &&
          json['imageUrls'].isNotEmpty) {
        imageUrl = json['imageUrls'][0];
      } else if (json['imageUrl'] != null) {
        imageUrl = json['imageUrl'];
      } else {
        imageUrl = json['thumbnailUrl'] ??
            json['thumbnail_url'] ??
            'https://via.placeholder.com/150';
      }

      // URL이 유효한지 확인 (http로 시작하는지)
      if (!imageUrl.startsWith('http')) {
        LoggerUtil.w('유효하지 않은 이미지 URL 형식: $imageUrl');
        imageUrl = 'https://via.placeholder.com/150';
      }

      // 펀딩 진행률 (API 명세서에 맞게 rate 키 우선 지원)
      final fundingPercentage = ((json['rate'] ??
              json['fundingPercentage'] ??
              json['funding_percentage'] ??
              json['percentage'] ??
              0) as num)
          .toDouble();

      // 펀딩 금액 (API 명세서에 맞게 price 키 우선 지원)
      final dynamic rawAmount = json['price'] ??
          json['fundingAmount'] ??
          json['funding_amount'] ??
          json['currentAmount'] ??
          json['amount'] ??
          0;

      String fundingAmount;
      if (rawAmount is num) {
        fundingAmount = rawAmount.toString();
      } else {
        fundingAmount = rawAmount.toString();
      }

      // 남은 일수 (API 명세서에 맞게 remainingDays 키 지원)
      final remainingDays =
          json['remainingDays'] ?? json['remaining_days'] ?? json['days'] ?? 0;

      // 활성화 상태 (API의 status 필드 활용 또는 isActive 직접 전달)
      bool isActive;
      if (json['isActive'] != null) {
        isActive = json['isActive'];
      } else if (json['is_active'] != null) {
        isActive = json['is_active'];
      } else if (json['status'] != null) {
        String status = json['status'].toString().toLowerCase();
        isActive = status == 'active' || status == 'ongoing' || status == '진행중';
      } else {
        // 기본값 (json에서 직접 전달되지 않을 경우)
        isActive = remainingDays > 0;
      }

      LoggerUtil.d(
          'SellerProjectModel.fromJson 변환 완료: {id: $id, title: $title}');

      return SellerProjectModel(
        id: id,
        title: title,
        companyName: companyName,
        imageUrl: imageUrl,
        fundingPercentage: fundingPercentage,
        fundingAmount: fundingAmount,
        remainingDays: remainingDays,
        isActive: isActive,
      );
    } catch (e) {
      LoggerUtil.e('SellerProjectModel.fromJson 변환 오류', e);
      // 오류 발생 시 기본 값으로 객체 생성
      return const SellerProjectModel(
        id: 0,
        title: '변환 오류',
        companyName: '회사명 없음',
        imageUrl: 'https://via.placeholder.com/150',
        fundingPercentage: 0.0,
        fundingAmount: '0',
        remainingDays: 0,
        isActive: false,
      );
    }
  }
}
