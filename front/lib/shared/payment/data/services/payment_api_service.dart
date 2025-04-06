import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/shared/payment/data/models/payment_dto.dart';
import 'package:front/shared/dummy/data/payment_dummy.dart';
import 'package:logger/logger.dart';

/// 결제 관련 API 서비스
class PaymentApiService {
  final ApiService _apiService;
  final Logger _logger = Logger();

  PaymentApiService(this._apiService);

  /// 결제 정보 조회 API
  Future<PaymentDTO> fetchPaymentInfo(String productId) async {
    try {
      _logger.d('결제 정보 조회 API 호출: $productId');

      // 실제 API 호출 구현 (현재는 Mock 데이터 반환)
      // final response = await _apiService.get('/api/payment/$productId');
      // return PaymentDTO.fromJson(response.data);

      // Mock 데이터 반환
      await Future.delayed(const Duration(milliseconds: 800));
      return paymentDummy;
    } catch (e) {
      _logger.e('결제 정보 조회 실패', error: e);
      rethrow;
    }
  }

  /// 쿠폰 적용 API
  Future<int> applyCoupon(String couponCode) async {
    try {
      _logger.d('쿠폰 적용 API 호출: $couponCode');

      // 실제 API 호출 구현
      // final response = await _apiService.post(
      //   '/api/payment/coupon',
      //   data: {'couponCode': couponCode},
      // );
      // return response.data['discountAmount'] as int;

      // Mock 데이터 반환
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockCouponDiscount(couponCode);
    } catch (e) {
      _logger.e('쿠폰 적용 실패', error: e);
      rethrow;
    }
  }

  /// 결제 처리 API
  Future<bool> processPayment(PaymentDTO payment) async {
    try {
      _logger.d('결제 처리 API 호출: ${payment.productId}');

      // API 명세에 맞게 요청 데이터 구조화
      final requestData = {
        "fundingld": int.parse(payment.productId), // fundingId는 productId와 동일
        "quantity": payment.quantity,
        "totalPrice": payment.finalAmount // 최종 결제 금액
      };

      _logger.d('결제 요청 데이터: $requestData');

      // 실제 API 호출 구현
      final response = await _apiService.post(
        '/user/order/funding',
        data: requestData,
      );

      // 응답 검증
      if (response.statusCode == 201) {
        _logger.i('결제 성공: 주문 ID ${response.data['content']['orderld']}');
        return true;
      } else {
        _logger.w('결제 실패: 상태 코드 ${response.statusCode}');
        throw DioException(
          requestOptions: RequestOptions(path: '/user/order/funding'),
          response: response,
          error: '결제에 실패했습니다. 상태 코드: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e('결제 처리 실패', error: e);
      if (e is DioException) {
        final errorMsg =
            e.response?.data?['status']?['message'] ?? '네트워크 오류가 발생했습니다.';
        throw Exception('결제 실패: $errorMsg');
      }
      rethrow;
    }
  }

  /// Mock 쿠폰 할인 데이터
  int _getMockCouponDiscount(String couponCode) {
    final mockCoupons = {
      'ECO5000': 5000,
      'GREEN10': 10000,
      'EARTH20': 20000,
    };

    final discountAmount = mockCoupons[couponCode.toUpperCase()];
    if (discountAmount == null) {
      throw Exception('존재하지 않는 쿠폰 코드입니다.');
    }

    return discountAmount;
  }
}

/// PaymentApiService Provider
final paymentApiServiceProvider = Provider<PaymentApiService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PaymentApiService(apiService);
});
