import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/shared/payment/data/models/payment_dto.dart';
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

      // 실제 API 호출 구현
      final response = await _apiService.get('/business/detail/$productId');
      _logger.d('🐛 Project detail API response: ${response.data}');

      if (response.statusCode == 200) {
        // API 응답에서 필요한 데이터 추출 (content 필드 안에 데이터가 있음)
        final content = response.data['content'];

        // 응답 구조에 따라 fundingInfo와 sellerInfo 추출
        final fundingInfo = content['fundingInfo'] ?? {};
        final sellerInfo = content['sellerInfo'] ?? {};

        _logger.d('🐛 fundingInfo: $fundingInfo');
        _logger.d('🐛 sellerInfo: $sellerInfo');

        // 이미지 URL 처리
        String imageUrl = '';
        if (fundingInfo['thumbnailFileUrl'] != null &&
            fundingInfo['thumbnailFileUrl'].toString().isNotEmpty) {
          imageUrl = fundingInfo['thumbnailFileUrl'];
        } else if (fundingInfo['imageUrls'] != null &&
            fundingInfo['imageUrls'] is List &&
            (fundingInfo['imageUrls'] as List).isNotEmpty) {
          imageUrl = fundingInfo['imageUrls'][0];
        }

        // 상품 정보를 PaymentDTO로 변환
        final paymentDTO = PaymentDTO(
          id: 'PAYMENT_${DateTime.now().millisecondsSinceEpoch}', // 고유 ID 생성
          productId: productId,
          productName: fundingInfo['title'] ?? '상품명 없음',
          sellerName: sellerInfo['sellerName'] ??
              fundingInfo['sellerName'] ??
              '판매자 정보 없음',
          imageUrl: imageUrl,
          price: fundingInfo['price'] is int ? fundingInfo['price'] : 0,
          quantity: 1, // 초기 수량 1로 설정
          couponDiscount: 0, // 초기 할인 없음
          recipientName: '', // 빈 값으로 설정
          address: '', // 빈 값으로 설정
          phoneNumber: '', // 빈 값으로 설정
          isDefaultAddress: false,
        );

        _logger.d('결제 정보 생성 완료: ${paymentDTO.productName}');
        return paymentDTO;
      } else {
        throw Exception('상품 정보를 가져오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('결제 정보 조회 실패', error: e);
      throw Exception('상품 정보를 가져오는데 실패했습니다: $e');
    }
  }

  /// 쿠폰 적용 API
  Future<int> applyCoupon(String couponCode) async {
    try {
      _logger.d('쿠폰 적용 API 호출: $couponCode');

      // 실제 API 호출 구현
      final response = await _apiService.post(
        '/user/order/coupon',
        data: {'couponCode': couponCode},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final discountAmount =
            response.data['content']['discountAmount'] as int;
        _logger.d('쿠폰 적용 성공: $couponCode, 할인액: $discountAmount');
        return discountAmount;
      } else {
        _logger.w('쿠폰 적용 실패: 상태 코드 ${response.statusCode}');
        throw Exception('쿠폰 적용에 실패했습니다. (${response.statusCode})');
      }
    } catch (e) {
      _logger.e('쿠폰 적용 실패', error: e);
      rethrow;
    }
  }

  /// 결제 처리 API
  Future<bool> processPayment({
    required String fundingId,
    required int quantity,
    required int totalPrice,
  }) async {
    try {
      _logger.d(
          '결제 처리 API 호출: fundingId=$fundingId, quantity=$quantity, totalPrice=$totalPrice');

      // API 명세에 맞게 요청 데이터 구조화 (필수 필드만 포함)
      final requestData = {
        "fundingId": int.parse(fundingId),
        "quantity": quantity,
        "totalPrice": totalPrice
      };

      // 실제 API 호출 구현
      final response = await _apiService.post(
        '/user/order/funding',
        data: requestData,
      );

      // 응답 검증
      if (response.statusCode == 201) {
        _logger.i('결제 성공: 주문 ID ${response.data['content']['orderId']}');
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

  /// 쿠폰 사용 처리 API (결제 성공 후 호출)
  Future<bool> useCoupon(int couponId) async {
    try {
      _logger.d('쿠폰 사용 처리 API 호출: couponId=$couponId');

      // API 엔드포인트 및 요청 데이터 구조
      final requestData = {
        "couponId": couponId,
      };

      // 실제 API 호출
      final response = await _apiService.post(
        '/user/order/coupon',
        data: requestData,
      );

      // 응답 검증
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('쿠폰 사용 처리 성공: $couponId');
        return true;
      } else {
        _logger.w('쿠폰 사용 처리 실패: 상태 코드 ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('쿠폰 사용 처리 실패', error: e);
      // 이 메서드는 결제 성공 후 호출되므로, 실패 시에도 예외를 던지지 않고 false 반환
      return false;
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
