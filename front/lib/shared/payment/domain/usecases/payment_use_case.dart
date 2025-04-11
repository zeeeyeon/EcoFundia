import 'package:front/shared/payment/domain/entities/payment_entity.dart';
import 'package:front/shared/payment/domain/repositories/payment_repository.dart';

/// 결제 관련 UseCase
class PaymentUseCase {
  final PaymentRepository _repository;

  PaymentUseCase(this._repository);

  /// 결제 정보 로드
  Future<PaymentEntity> loadPaymentInfo(String productId) async {
    return await _repository.getPaymentInfo(productId);
  }

  /// 쿠폰 적용
  Future<int> applyCoupon(String couponCode) async {
    return await _repository.applyCoupon(couponCode);
  }

  /// 결제 처리
  Future<bool> processPayment(PaymentEntity payment) async {
    return await _repository.processPayment(payment);
  }
}
