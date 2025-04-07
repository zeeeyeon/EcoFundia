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
          '결제 요청 데이터: fundingId=$fundingId, quantity=$quantity, totalPrice=$totalPrice, couponId=${payment.appliedCouponId}');

      // 결제 API 호출
      final paymentResult = await _apiService.processPayment(
        fundingId: fundingId,
        quantity: quantity,
        totalPrice: totalPrice,
      );

      // 결제가 성공하고, 쿠폰이 적용된 경우 쿠폰 사용 처리
      if (paymentResult && payment.appliedCouponId > 0) {
        _logger.d('결제 성공, 쿠폰 사용 처리 시작: couponId=${payment.appliedCouponId}');

        try {
          // 여기서는 Repository 내에서 직접 API를 호출하지 않고,
          // 관심사 분리를 위해 UseCase를 사용하는 것이 이상적이나,
          // 편의상 여기에서 API를 호출하는 코드를 추가합니다.
          // 실제 구현에서는 이 부분을 외부에서 주입받은 UseCouponUseCase를 사용하거나,
          // 성공 후 별도 처리가 필요한 경우 위에서 호출하도록 구조를 변경해야 합니다.

          await _apiService.useCoupon(payment.appliedCouponId);
          _logger.d('쿠폰 사용 처리 완료: couponId=${payment.appliedCouponId}');
        } catch (couponError) {
          // 쿠폰 사용 처리 실패는 결제 성공에 영향을 주지 않습니다.
          // 로그만 남기고 결제는 성공으로 처리합니다.
          _logger.e('쿠폰 사용 처리 실패 (무시됨): ${couponError.toString()}');
        }
      }

      return paymentResult;
    } catch (e) {
      _logger.e('결제 처리 실패', error: e);
      rethrow;
    }
  }
}
