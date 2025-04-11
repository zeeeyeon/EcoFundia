import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/config/app_config.dart';

/// JWT 토큰 관리를 위한 서비스
class TokenService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
    headers: {'Accept': 'application/json'},
    validateStatus: (status) => true,
  ));

  /// 토큰 갱신 시도
  static Future<Map<String, String>?> refreshTokens(String refreshToken) async {
    try {
      LoggerUtil.i('🔄 토큰 갱신 시도 (TokenService)');

      // 토큰 갱신 API 엔드포인트
      final reissueEndpoint = AppConfig.apiEndpoints.reissue;

      // 토큰 갱신 요청
      final response = await _dio.post(
        reissueEndpoint,
        data: {'refreshToken': refreshToken},
        options: Options(
            headers: {'X-Skip-Token-Refresh': 'true'},
            validateStatus: (status) => status != null && status < 500),
      );

      // 응답 확인
      if (response.statusCode == 200 && response.data != null) {
        // 새 토큰 추출
        final newAccessToken = response.data['content']['accessToken'];
        final newRefreshToken = response.data['content']['refreshToken'];

        LoggerUtil.i('✅ 토큰 갱신 성공 (TokenService)');

        // 새 토큰 반환
        return {
          'accessToken': newAccessToken,
          'refreshToken': newRefreshToken,
        };
      } else {
        LoggerUtil.w('⚠️ 토큰 갱신 실패: API 응답 오류 (${response.statusCode})');
        // 401, 403 응답의 경우 로그아웃 처리가 필요함을 알림
        return null;
      }
    } catch (e) {
      LoggerUtil.e('❌ 토큰 갱신 요청 중 오류 발생', e);
      return null;
    }
  }

  /// 토큰의 만료 시간까지 남은 시간(분) 계산
  static int? calculateMinutesToExpiration(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final expirationTime = DateTime.fromMillisecondsSinceEpoch(
        decodedToken['exp'] * 1000,
      );
      final now = DateTime.now();
      return expirationTime.difference(now).inMinutes;
    } catch (e) {
      LoggerUtil.e('❌ 토큰 만료 시간 계산 중 오류', e);
      return null;
    }
  }

  /// 토큰 유효성 검사
  static bool isValidToken(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['exp'] != null && decodedToken['sub'] != null;
    } catch (e) {
      LoggerUtil.e('❌ 토큰 유효성 검사 실패', e);
      return false;
    }
  }

  /// 토큰 만료 여부 확인
  static bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      LoggerUtil.e('❌ 토큰 만료 확인 중 오류', e);
      return true; // 오류 발생 시 만료된 것으로 간주
    }
  }
}
