import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/features/mypage/data/models/coupon_model.dart';
import 'package:front/features/mypage/domain/entities/coupon_apply_result.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/services/storage_service.dart';

/// 쿠폰 API 서비스
class CouponService {
  final ApiService _apiService;

  CouponService(this._apiService);

  /// 사용자 쿠폰 개수 조회
  /// [GET /api/user/coupons/count]
  Future<int> getCouponCount() async {
    try {
      final response = await _apiService.get(
        ApiService.apiEndpoints.couponCount,
      );

      final responseModel = CouponResponseModel.fromJson(response.data);

      if (responseModel.isSuccess) {
        final count = responseModel.content as int;
        LoggerUtil.d('✅ 쿠폰 개수 조회 성공: $count장');
        return count;
      } else {
        throw Exception('쿠폰 개수 조회 실패: ${responseModel.message}');
      }
    } catch (e) {
      LoggerUtil.e('❌ 쿠폰 개수 조회 실패', e);
      rethrow;
    }
  }

  /// 쿠폰 목록 조회
  /// [GET /api/user/coupons/list]
  Future<List<CouponModel>> getCouponList() async {
    try {
      LoggerUtil.d('🎫 쿠폰 목록 조회 요청');

      final response = await _apiService.get(
        ApiService.apiEndpoints.couponList,
      );

      final responseModel = CouponResponseModel.fromJson(response.data);

      if (responseModel.isSuccess && responseModel.content is List) {
        final coupons = CouponModel.fromJsonList(responseModel.content);
        LoggerUtil.d('✅ 쿠폰 목록 조회 성공: ${coupons.length}개');
        return coupons;
      } else {
        LoggerUtil.w('⚠️ 쿠폰 목록 조회 결과 없음');
        return [];
      }
    } catch (e) {
      LoggerUtil.e('❌ 쿠폰 목록 조회 실패', e);
      if (e is DioException && e.response?.statusCode == 404) {
        // 쿠폰이 없는 경우 빈 목록 반환
        return [];
      }
      rethrow;
    }
  }

  /// 쿠폰 발급 신청 API 호출
  /// [POST /api/user/coupons/apply]
  ///
  /// 반환 타입: [CouponApplyResult]
  /// - [CouponApplySuccess] - 쿠폰 발급 성공
  /// - [AlreadyIssuedFailure] - 이미 발급된 쿠폰 (400 응답)
  /// - [AuthorizationFailure] - 권한 없음 (403 응답) - 로그인 필요
  /// - [NetworkFailure] - 네트워크 오류
  /// - [UnknownFailure] - 알 수 없는 오류
  Future<CouponApplyResult> applyCoupon() async {
    try {
      LoggerUtil.d('🎫 CouponService: 쿠폰 발급 신청 요청 시작');

      // 인증 상태 확인 (StorageService에서 비동기적으로 확인)
      bool isAuthenticated = false;
      try {
        isAuthenticated = await StorageService.isAuthenticated();
      } catch (e) {
        LoggerUtil.e('🎫 인증 상태 확인 중 오류', e);
      }

      // 로그인 상태가 아니면 API 호출 없이 즉시 권한 오류 반환
      if (!isAuthenticated) {
        LoggerUtil.w('🎫 CouponService: 권한 없음 - 로그인이 필요합니다 (로컬 확인)');
        return const AuthorizationFailure();
      }

      final endpoint = ApiService.apiEndpoints.couponApply;
      LoggerUtil.d('🎫 CouponService: API 엔드포인트: $endpoint');

      // 중요: API 호출 전에 로그 추가
      LoggerUtil.d('🎫 POST 요청 직전: $endpoint');

      // 타임아웃 옵션 추가하여 더 빠른 응답 보장
      final options = Options(
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          'X-Request-Time': DateTime.now().toString(),
        },
      );

      final response = await _apiService.post(
        endpoint,
        options: options,
      );

      // API 응답 로그
      LoggerUtil.d(
          '🎫 CouponService: API 응답 수신: status=${response.statusCode}');
      LoggerUtil.d('🎫 CouponService: API 응답 데이터: ${response.data}');

      // 상태 코드에 따른 처리
      return switch (response.statusCode) {
        // 성공 (200 또는 201)
        200 || 201 => _handleSuccessResponse(response),

        // 이미 발급된 쿠폰 (400)
        400 => _handleBadRequestResponse(response),

        // 권한 없음 - 로그인 필요 (403)
        403 => _handleForbiddenResponse(response),

        // 시간 제한 (404)
        404 => _handleTimeLimitResponse(response),

        // 기타 상태 코드
        _ => _handleUnknownResponse(response),
      };
    } on DioException catch (e) {
      LoggerUtil.e('🎫 CouponService: API 호출 실패', e);

      // 응답 상태 코드에 따른 처리
      if (e.response != null) {
        final statusCode = e.response!.statusCode;

        return switch (statusCode) {
          // 이미 발급된 쿠폰 (400)
          400 => _handleBadRequestResponse(e.response!),
          // 권한 없음 - 로그인 필요 (403)
          403 => _handleForbiddenResponse(e.response!),
          // 시간 제한 (404)
          404 => _handleTimeLimitResponse(e.response!),
          // 기타 Dio 오류는 아래에서 처리
          _ => _handleDioError(e),
        };
      } else {
        // 응답이 없는 Dio 오류 (네트워크 등)
        return _handleDioError(e);
      }
    } catch (e) {
      LoggerUtil.e('🎫 CouponService: 알 수 없는 예외 발생', e);
      return UnknownFailure('알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 성공 응답 처리 (200, 201)
  CouponApplyResult _handleSuccessResponse(Response response) {
    LoggerUtil.i('🎫 CouponService: 쿠폰 발급 성공 (상태 코드: ${response.statusCode})');
    return const CouponApplySuccess();
  }

  // 400 Bad Request 응답 처리 (이미 발급된 쿠폰)
  CouponApplyResult _handleBadRequestResponse(Response response) {
    LoggerUtil.w('🎫 CouponService: 이미 발급된 쿠폰 (상태 코드: 400)');
    return const AlreadyIssuedFailure();
  }

  // 403 Forbidden 응답 처리 (권한 없음)
  CouponApplyResult _handleForbiddenResponse(Response response) {
    LoggerUtil.w('🎫 CouponService: 권한 없음 - 로그인 필요 (상태 코드: 403)');
    return const AuthorizationFailure();
  }

  // 404 Not Found 응답 처리 (시간 제한)
  CouponApplyResult _handleTimeLimitResponse(Response response) {
    LoggerUtil.w('🎫 CouponService: 쿠폰 발급 시간 제한 (상태 코드: 404)');
    // 백엔드에서 메시지를 보내준다면 사용, 없다면 기본 메시지 사용
    String message = response.data?['message'] ?? "쿠폰 발급은 오전 10시부터 가능합니다.";
    return CouponTimeLimitFailure(message);
  }

  // 기타 알 수 없는 응답 처리
  CouponApplyResult _handleUnknownResponse(Response response) {
    LoggerUtil.e('🎫 CouponService: 예상치 못한 상태 코드: ${response.statusCode}');
    return UnknownFailure('서버에서 예상치 못한 응답이 반환되었습니다 (${response.statusCode})');
  }

  // DioException 처리 로직 통합
  CouponApplyResult _handleDioError(DioException e) {
    // 타임아웃 에러 특별 처리
    if (e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionTimeout) {
      LoggerUtil.e('🎫 CouponService: 타임아웃 발생', e);
      return const NetworkFailure('쿠폰 발급 요청 시간 초과');
    }

    // 그 외 DioException (네트워크, 서버 오류 등)
    LoggerUtil.e('🎫 CouponService: 네트워크 또는 서버 오류', e);
    return NetworkFailure('쿠폰 발급에 실패했습니다: ${e.message ?? '네트워크 오류'}');
  }

  /// 사용 가능한 쿠폰 목록 조회 (결제 시)
  /// 결제 화면에서 사용할 수 있는 쿠폰 목록을 조회할 때 사용
  Future<List<CouponModel>> getAvailableCoupons() async {
    try {
      LoggerUtil.d('🎫 사용 가능한 쿠폰 목록 조회 요청');

      final response = await _apiService.get(
        ApiService.apiEndpoints.couponList,
      );

      final responseModel = CouponResponseModel.fromJson(response.data);

      if (responseModel.isSuccess && responseModel.content is List) {
        final coupons = CouponModel.fromJsonList(responseModel.content);
        return coupons;
      } else {
        return [];
      }
    } catch (e) {
      LoggerUtil.e('❌ 사용 가능한 쿠폰 목록 조회 실패', e);
      if (e is DioException && e.response?.statusCode == 404) {
        // 쿠폰이 없는 경우 빈 목록 반환
        return [];
      }
      rethrow;
    }
  }
}

/// 쿠폰 서비스 Provider
final couponServiceProvider = Provider<CouponService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CouponService(apiService);
});
