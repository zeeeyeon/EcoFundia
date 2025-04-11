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

  /// 결제 처리 API
  Future<bool> processPayment({
    required String fundingId,
    required int quantity,
    required int productPrice,
    int? couponId,
  }) async {
    try {
      _logger.d(
          '결제 처리 API 호출: fundingId=$fundingId, quantity=$quantity, productPrice=$productPrice, couponId=$couponId');

      // API 명세에 맞게 요청 데이터 구조화
      final requestData = {
        "fundingId": int.parse(fundingId),
        "quantity": quantity,
        "totalPrice": productPrice,
      };

      // couponId가 null이 아니고 0보다 큰 경우에만 요청에 포함
      if (couponId != null && couponId > 0) {
        requestData["couponId"] = couponId;
        _logger.d('쿠폰 적용 포함 결제 요청: couponId=$couponId');
      } else {
        _logger.d('쿠폰 미적용 결제 요청');
      }

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
}

/// PaymentApiService Provider
final paymentApiServiceProvider = Provider<PaymentApiService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PaymentApiService(apiService);
});
