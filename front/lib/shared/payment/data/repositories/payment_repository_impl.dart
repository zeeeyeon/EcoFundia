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

      // 사용자 주소 정보 없이 기본 빈 값 사용
      final finalDTO = PaymentDTO(
        id: paymentDTO.id,
        productId: paymentDTO.productId,
        productName: paymentDTO.productName,
        sellerName: paymentDTO.sellerName,
        imageUrl: paymentDTO.imageUrl,
        price: paymentDTO.price,
        quantity: paymentDTO.quantity,
        couponDiscount: paymentDTO.couponDiscount,
        recipientName: '', // 빈 값으로 설정
        address: '', // 빈 값으로 설정
        phoneNumber: '', // 빈 값으로 설정
        isDefaultAddress: false,
      );

      // DTO를 Entity로 변환하여 반환
      return finalDTO.toEntity();
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

      // Entity에서 API 요청에 필요한 필수 데이터만 추출
      final String fundingId = payment.productId;
      final int quantity = payment.quantity;

      // 최종 결제 금액 계산 (상품 가격 × 수량 - 쿠폰 할인)
      final int totalPrice = payment.finalAmount;

      _logger.d(
          '결제 요청 데이터: fundingId=$fundingId, quantity=$quantity, totalPrice=$totalPrice');

      // 필요한 데이터만 API 서비스에 전달
      return await _apiService.processPayment(
        fundingId: fundingId,
        quantity: quantity,
        totalPrice: totalPrice,
      );
    } catch (e) {
      _logger.e('결제 처리 실패', error: e);
      rethrow;
    }
  }
}
