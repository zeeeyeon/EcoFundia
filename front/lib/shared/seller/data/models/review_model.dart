import 'package:front/shared/seller/domain/entities/review_entity.dart';
import 'package:front/utils/logger_util.dart';

/// 리뷰 API 응답 모델
class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.userName,
    required super.rating,
    required super.content,
    required super.productName,
    required super.createdAt,
    required super.userId,
    required super.fundingId,
  });

  /// API 응답 JSON을 ReviewModel로 변환
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    try {
      LoggerUtil.d('ReviewModel.fromJson 변환 시작: $json');

      // ID 처리 (문자열 또는 숫자)
      dynamic rawId = json['id'] ?? json['reviewId'] ?? json['reviewld'] ?? 0;
      int id;
      if (rawId is String) {
        id = int.tryParse(rawId) ?? 0;
      } else {
        id = rawId as int;
      }

      // userId 처리 (API 명세의 오타 'userld' 처리 포함)
      dynamic rawUserId =
          json['userId'] ?? json['userld'] ?? json['user_id'] ?? 0;
      int userId;
      if (rawUserId is String) {
        userId = int.tryParse(rawUserId) ?? 0;
      } else {
        userId = rawUserId as int;
      }

      // fundingId 처리 (API 명세의 오타 'fundingld' 처리 포함)
      dynamic rawFundingId =
          json['fundingId'] ?? json['fundingld'] ?? json['funding_id'] ?? 0;
      int fundingId;
      if (rawFundingId is String) {
        fundingId = int.tryParse(rawFundingId) ?? 0;
      } else {
        fundingId = rawFundingId as int;
      }

      // 사용자 이름
      final userName = json['userName'] ??
          json['user_name'] ??
          json['nickname'] ??
          json['name'] ??
          '사용자';

      // 별점
      final rating =
          ((json['rating'] ?? json['rate'] ?? json['score'] ?? 0) as num)
              .toDouble();

      // 리뷰 내용
      final content = json['content'] ??
          json['reviewContent'] ??
          json['review_content'] ??
          json['text'] ??
          '';

      // 상품명
      final productName = json['productName'] ??
          json['product_name'] ??
          json['fundingTitle'] ??
          json['funding_title'] ??
          json['title'] ??
          '상품명 없음';

      // 날짜 처리
      String createdAtStr = json['createdAt'] ??
          json['created_at'] ??
          json['date'] ??
          DateTime.now().toIso8601String();

      DateTime createdAt;
      try {
        createdAt = DateTime.parse(createdAtStr);
      } catch (e) {
        // 오류 메시지와 예외 정보를 합쳐서 한 문자열로 전달
        LoggerUtil.w(
            'ReviewModel 날짜 파싱 실패: $createdAtStr - 오류: ${e.toString()}');
        createdAt = DateTime.now(); // 날짜 파싱 실패 시 현재 시간 사용
      }

      LoggerUtil.d(
          'ReviewModel.fromJson 변환 완료: {id: $id, userName: $userName, rating: $rating, userId: $userId, fundingId: $fundingId}');

      return ReviewModel(
        id: id,
        userName: userName,
        rating: rating,
        content: content,
        productName: productName,
        createdAt: createdAt,
        userId: userId,
        fundingId: fundingId,
      );
    } catch (e) {
      LoggerUtil.e('ReviewModel.fromJson 변환 오류', e);
      // 오류 발생 시 기본 값으로 객체 생성
      return ReviewModel(
        id: 0,
        userName: '변환 오류',
        rating: 0.0,
        content: '',
        productName: '상품명 없음',
        createdAt: DateTime.now(),
        userId: 0,
        fundingId: 0,
      );
    }
  }
}
