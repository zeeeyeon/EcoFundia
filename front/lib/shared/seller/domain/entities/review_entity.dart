import 'package:equatable/equatable.dart';

/// 리뷰 정보를 표현하는 엔티티 클래스
class ReviewEntity extends Equatable {
  final int id;
  final String userName; // 사용자 이름 (마스킹된 형태, 예: "도**")
  final double rating; // 별점 (1-5)
  final String content; // 리뷰 내용
  final String productName; // 제품 이름 (예: "[존맛탱구리1] 슈퍼바나나 맛도 슈퍼다!!")
  final DateTime createdAt; // 리뷰 작성 시간

  const ReviewEntity({
    required this.id,
    required this.userName,
    required this.rating,
    required this.content,
    required this.productName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userName,
        rating,
        content,
        productName,
        createdAt,
      ];
}
