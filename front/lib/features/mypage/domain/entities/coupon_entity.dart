import 'package:equatable/equatable.dart';

/// 쿠폰 도메인 엔티티
class CouponEntity extends Equatable {
  final int couponId;
  final String couponCode;
  final String name;
  final String description;
  final String type; // 'FIXED_AMOUNT' or 'PERCENTAGE'
  final int discountAmount;
  final int discountRate;
  final int maxDiscountAmount;
  final int minOrderAmount;
  final String expirationDate;
  final bool isUsed;
  final int totalQuantity;
  final DateTime startDate;
  final DateTime endDate;

  const CouponEntity({
    required this.couponId,
    required this.couponCode,
    this.name = '',
    this.description = '',
    this.type = 'FIXED_AMOUNT',
    required this.discountAmount,
    this.discountRate = 0,
    this.maxDiscountAmount = 0,
    this.minOrderAmount = 0,
    required this.expirationDate,
    this.isUsed = false,
    required this.totalQuantity,
    required this.startDate,
    required this.endDate,
  });

  /// 쿠폰이 현재 유효한지 확인
  bool get isValid {
    final now = DateTime.now();
    try {
      final expDate = DateTime.parse(expirationDate);
      return now.isBefore(expDate) && !isUsed;
    } catch (e) {
      // 기존 방식으로 체크(하위 호환성 유지)
      return now.isAfter(startDate) && now.isBefore(endDate) && !isUsed;
    }
  }

  /// 남은 유효 기간(일)
  int get daysRemaining {
    final now = DateTime.now();
    try {
      final expDate = DateTime.parse(expirationDate);
      final difference = expDate.difference(now);
      return difference.inDays;
    } catch (e) {
      // 기존 방식으로 계산(하위 호환성 유지)
      final difference = endDate.difference(now);
      return difference.inDays;
    }
  }

  @override
  List<Object?> get props => [
        couponId,
        couponCode,
        name,
        description,
        type,
        discountAmount,
        discountRate,
        maxDiscountAmount,
        minOrderAmount,
        expirationDate,
        isUsed,
        totalQuantity,
        startDate,
        endDate,
      ];
}
