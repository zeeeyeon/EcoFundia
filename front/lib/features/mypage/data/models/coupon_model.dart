import 'package:equatable/equatable.dart';
import 'package:front/features/mypage/domain/entities/coupon_entity.dart';

/// 쿠폰 API 응답 모델
class CouponModel extends Equatable {
  final int couponId;
  final String couponCode;
  final int totalQuantity;
  final int discountAmount;
  final DateTime startDate;
  final DateTime endDate;

  const CouponModel({
    required this.couponId,
    required this.couponCode,
    required this.totalQuantity,
    required this.discountAmount,
    required this.startDate,
    required this.endDate,
  });

  /// JSON에서 모델 객체 생성
  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      couponId: json['couponId'] as int,
      couponCode: json['couponCode'].toString(),
      totalQuantity: json['totalQuantity'] as int,
      discountAmount: json['discountAmount'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  /// 모델을 도메인 엔티티로 변환
  CouponEntity toEntity() {
    return CouponEntity(
      couponId: couponId,
      couponCode: couponCode,
      totalQuantity: totalQuantity,
      discountAmount: discountAmount,
      startDate: startDate,
      endDate: endDate,
      expirationDate: endDate.toString(),
    );
  }

  /// 리스트 형태의 JSON을 모델 리스트로 변환하는 편의 메서드
  static List<CouponModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => CouponModel.fromJson(json)).toList();
  }

  @override
  List<Object?> get props => [
        couponId,
        couponCode,
        totalQuantity,
        discountAmount,
        startDate,
        endDate,
      ];
}

/// 쿠폰 API 응답 래퍼 모델
class CouponResponseModel {
  final int statusCode;
  final String message;
  final dynamic content;

  const CouponResponseModel({
    required this.statusCode,
    required this.message,
    this.content,
  });

  factory CouponResponseModel.fromJson(Map<String, dynamic> json) {
    return CouponResponseModel(
      statusCode: json['status']['code'] as int,
      message: json['status']['message'] as String,
      content: json['content'],
    );
  }

  bool get isSuccess => statusCode == 200 || statusCode == 201;
}
