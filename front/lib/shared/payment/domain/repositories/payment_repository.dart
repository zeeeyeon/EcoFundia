import 'package:front/shared/payment/domain/entities/payment_entity.dart';

/// 결제 관련 Repository 인터페이스
abstract class PaymentRepository {
  /// 결제 정보 가져오기
  Future<PaymentEntity> getPaymentInfo(String productId);

  /// 쿠폰 적용
  Future<int> applyCoupon(String couponCode);

  /// 결제 처리
  Future<bool> processPayment(PaymentEntity payment);
}
