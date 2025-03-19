import 'package:front/features/auth/domain/models/auth_response.dart';
import 'package:front/utils/logger_util.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:front/core/exceptions/auth_exception.dart';
import 'package:front/core/services/api_service.dart';

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

      LoggerUtil.i('✅ 액세스 토큰 획득 성공');
      return accessToken;
    } catch (e) {
      LoggerUtil.e('❌ Google 액세스 토큰 획득 실패', e);
      rethrow;
    }
  }

  /// Google 인증 처리
  Future<AuthResponse> authenticateWithGoogle(String accessToken) async {
    try {
      // Dio를 사용하여 API 요청
      final response = await _apiService.post(
        ApiService.apiEndpoints.login,
        data: {'token': accessToken},
      );

      final statusCode = response.statusCode;
      LoggerUtil.i('🔄 서버 응답: 상태코드=$statusCode');

      if (statusCode == 200) {
        final data = response.data;
        return AuthResponse.fromJson(data);
      } else if (statusCode == 404) {
        // 회원가입이 필요한 경우
        final data = response.data;
        final message =
            data['message'] as String? ?? '해당 이메일로 가입된 사용자가 없습니다. 회원가입이 필요합니다.';
        throw AuthException(message, statusCode: 404);
      } else {
        // 기타 오류
        String message;
        try {
          final data = response.data;
          message = data['message'] as String? ?? '서버 인증 중 오류가 발생했습니다.';
        } catch (_) {
          message = '서버 인증 중 오류가 발생했습니다.';
        }
        throw AuthException(message, statusCode: statusCode);
      }
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
