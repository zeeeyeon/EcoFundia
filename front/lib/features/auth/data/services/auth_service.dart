import 'package:front/features/auth/data/models/auth_response_model.dart';
import 'package:front/utils/logger_util.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:front/core/exceptions/auth_exception.dart';
import 'package:front/core/services/api_service.dart';
import 'package:dio/dio.dart';

class AuthService {
  final ApiService _apiService;
  final GoogleSignIn _googleSignIn;

  AuthService({
    required ApiService apiService,
    required GoogleSignIn googleSignIn,
  })  : _apiService = apiService,
        _googleSignIn = googleSignIn;

  /// GoogleSignIn 인스턴스에 접근하기 위한 getter
  GoogleSignIn get googleSignIn => _googleSignIn;

  /// Google 액세스 토큰 획득
  Future<String?> getGoogleAccessToken() async {
    try {
      LoggerUtil.i('🔑 AuthService - Google 로그인 프로세스 시작');

      // Google 로그인 UI 표시
      final account = await _googleSignIn.signIn();
      if (account == null) {
        LoggerUtil.w('⚠️ 사용자가 Google 로그인을 취소했습니다.');
        return null;
      }

      LoggerUtil.i('👤 Google 계정 선택 완료: ${account.email}');

      // 인증 정보 획득
      final auth = await account.authentication;
      final accessToken = auth.accessToken;

      if (accessToken == null) {
        LoggerUtil.e('⚠️ 액세스 토큰을 획득하지 못했습니다.');
        throw AuthException('액세스 토큰을 획득하지 못했습니다.');
      }

      LoggerUtil.i(
          '✅ 액세스 토큰 획득 성공: ${accessToken.substring(0, min(10, accessToken.length))}...');
      return accessToken;
    } catch (e) {
      LoggerUtil.e('❌ Google 액세스 토큰 획득 실패', e);
      rethrow;
    }
  }

  /// Google 인증 처리
  Future<AuthResponseModel> authenticateWithGoogle(String accessToken) async {
    try {
      // Dio를 사용하여 API 요청
      final response = await _apiService.post(
        ApiService.apiEndpoints.login,
        data: {'token': accessToken},
      );

      final data = response.data;
      LoggerUtil.i('🔄 서버 응답: 상태코드=${response.statusCode}');

      // 응답 데이터 검증
      if (response.statusCode == 200) {
        if (data == null) {
          throw AuthException('서버 응답이 비어있습니다.');
        }

        // status 코드 검증
        final status = data['status'];
        if (status == null || status['code'] != '201') {
          throw AuthException(status?['message'] ?? '서버 응답이 올바르지 않습니다.');
        }

        return AuthResponseModel.fromJson(data);
      }

      throw AuthException('예상치 못한 응답 코드: ${response.statusCode}');
    } on DioException catch (e) {
      LoggerUtil.e('❌ Google 인증 처리 실패', e);

      if (e.response?.statusCode == 404) {
        // 회원가입이 필요한 경우
        LoggerUtil.i('신규 회원: 회원가입이 필요합니다.');
        throw AuthException('회원가입이 필요합니다.', statusCode: 404, isNewUser: true);
      }

      // 기타 오류
      String message = '서버 인증 중 오류가 발생했습니다.';
      try {
        if (e.response?.data != null) {
          message = e.response?.data['status']?['message'] ?? message;
        }
      } catch (_) {}
      throw AuthException(message, statusCode: e.response?.statusCode);
    } catch (e) {
      LoggerUtil.e('❌ Google 인증 처리 실패', e);
      if (e is AuthException) rethrow;
      throw AuthException('인증 처리 중 오류가 발생했습니다.', statusCode: 500);
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      LoggerUtil.e('❌ Google 로그아웃 실패', e);
      rethrow;
    }
  }
}
