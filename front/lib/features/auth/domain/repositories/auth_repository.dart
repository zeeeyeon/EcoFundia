import '../models/auth_response.dart';
import '../models/google_sign_in_result.dart';

/// 인증 관련 작업을 처리하는 저장소 인터페이스
abstract class AuthRepository {
  /// Google 로그인 진행 및 인가 코득
  Future<String?> getGoogleAuthCode();

  /// 서버에 인가 코드 전송 및 JWT 획득
  Future<AuthResponse> authenticateWithGoogle(String authCode);

  /// 회원가입 완료 후 토큰 획득
  Future<AuthResponse> completeSignUp(Map<String, dynamic> userData);

  /// 로그아웃
  Future<void> signOut();

  /// 로그인 상태 확인
  Future<bool> isLoggedIn();
}
