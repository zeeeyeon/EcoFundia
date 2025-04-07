import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/data/repositories/coupon_repository_impl.dart';
import 'package:front/shared/payment/domain/entities/payment_entity.dart';
import 'package:front/shared/payment/domain/repositories/payment_repository.dart';
import 'package:front/shared/payment/data/services/payment_api_service.dart';
import 'package:front/shared/payment/data/models/payment_dto.dart';

/// 결제 관련 Repository 구현
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentApiService _apiService;
  final Logger _logger = Logger();
  final Ref _ref;

  PaymentRepositoryImpl(this._apiService, this._ref);

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
        appliedCouponId: paymentDTO.appliedCouponId,
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

      // CouponRepository를 통해 쿠폰 조회 및 할인액 계산
      final couponRepository = _ref.read(couponRepositoryProvider);
      final availableCoupons = await couponRepository.getAvailableCoupons();

      if (availableCoupons.isEmpty) {
        _logger.w('사용 가능한 쿠폰이 없습니다.');
        throw Exception('사용 가능한 쿠폰이 없습니다.');
      }

      // 해당 코드에 맞는 쿠폰 찾기
      final coupon = availableCoupons.firstWhere(
          (c) => c.couponCode == couponCode,
          orElse: () => throw Exception('존재하지 않는 쿠폰 코드입니다.'));

      _logger.d('쿠폰 적용 성공: $couponCode, 할인액: ${coupon.discountAmount}');
      return coupon.discountAmount;
    } catch (e) {
      _logger.e('쿠폰 적용 실패', error: e);
      rethrow;
    }
  }

  @override
  Future<bool> processPayment(PaymentEntity payment) async {
    try {
      _logger.d('결제 처리: ${payment.id}');

      // Entity에서 API 요청에 필요한 데이터 추출
      final String fundingId = payment.productId;
      final int quantity = payment.quantity;
      final int appliedCouponId = payment.appliedCouponId;

      // 최종 결제 금액 계산 (상품 가격 × 수량 - 쿠폰 할인)
      final int totalPrice = payment.finalAmount;

      _logger.d(
          '결제 요청 데이터: fundingId=$fundingId, quantity=$quantity, totalPrice=$totalPrice, couponId=${payment.appliedCouponId}');

      // 결제 API 호출 - 쿠폰 ID를 포함하여 요청
      final paymentResult = await _apiService.processPayment(
        fundingId: fundingId,
        quantity: quantity,
        totalPrice: totalPrice,
        couponId: appliedCouponId > 0 ? appliedCouponId : null,
      );

      return paymentResult;
    } catch (e) {
      _logger.e('결제 처리 실패', error: e);
      rethrow;
    }
  }
}

/// PaymentRepository Provider
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final apiService = ref.watch(paymentApiServiceProvider);
  return PaymentRepositoryImpl(apiService, ref);
});
