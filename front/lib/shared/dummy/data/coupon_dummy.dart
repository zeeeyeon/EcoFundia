/// 쿠폰 더미 데이터 모델
class CouponDummy {
  final String code;
  final String name;
  final int amount;
  final String expiryDate;

  const CouponDummy({
    required this.code,
    required this.name,
    required this.amount,
    required this.expiryDate,
  });
}

/// 쿠폰 더미 데이터 목록
const List<CouponDummy> couponDummyList = [
  CouponDummy(
    code: 'COUPON_10000',
    name: '정률쿠폰 10,000원 할인쿠폰',
    amount: 10000,
    expiryDate: '2025.03.20 23시 59분',
  ),
  CouponDummy(
    code: 'COUPON_5000',
    name: '정률쿠폰 5,000원 할인쿠폰',
    amount: 5000,
    expiryDate: '2025.03.20 23시 59분',
  ),
];
