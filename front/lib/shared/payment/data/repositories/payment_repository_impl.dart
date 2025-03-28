import 'package:logger/logger.dart';
import 'package:front/shared/payment/domain/entities/payment_entity.dart';
import 'package:front/shared/payment/domain/repositories/payment_repository.dart';
import 'package:front/shared/payment/data/services/payment_api_service.dart';
import 'package:front/shared/payment/data/models/payment_dto.dart';

/// 결제 관련 Repository 구현
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentApiService _apiService;
  final Logger _logger = Logger();

  PaymentRepositoryImpl(this._apiService);

  @override
  Future<PaymentEntity> getPaymentInfo(String productId) async {
    try {
      _logger.d('결제 정보 로드: $productId');

      // API 서비스를 통해 데이터 가져오기
      final paymentDTO = await _apiService.fetchPaymentInfo(productId);

      // DTO를 Entity로 변환하여 반환
      return paymentDTO.toEntity();
    } catch (e) {
      _logger.e('결제 정보 로드 실패', error: e);
      rethrow;
    }
  }

  @override
  Future<int> applyCoupon(String couponCode) async {
    try {
      _logger.d('쿠폰 적용: $couponCode');

      // API 서비스를 통해 쿠폰 적용
      return await _apiService.applyCoupon(couponCode);
    } catch (e) {
      _logger.e('쿠폰 적용 실패', error: e);
      rethrow;
    }
  }

  @override
  Future<bool> processPayment(PaymentEntity payment) async {
    try {
      _logger.d('결제 처리: ${payment.id}');

      // Entity를 DTO로 변환 (여기서는 간단히 새로 생성)
      final paymentDTO = PaymentDTO(
        id: payment.id,
        productId: payment.productId,
        productName: payment.productName,
        sellerName: payment.sellerName,
        imageUrl: payment.imageUrl,
        price: payment.price,
        quantity: payment.quantity,
        couponDiscount: payment.couponDiscount,
        recipientName: payment.recipientName,
        address: payment.address,
        phoneNumber: payment.phoneNumber,
        isDefaultAddress: payment.isDefaultAddress,
      );

      // API 서비스를 통해 결제 처리
      return await _apiService.processPayment(paymentDTO);
    } catch (e) {
      _logger.e('결제 처리 실패', error: e);
      rethrow;
    }
  }
}
