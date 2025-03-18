import '../models/auth_response.dart';

/// 인증 관련 작업을 처리하는 저장소 인터페이스
abstract class AuthRepository {
  /// Google 로그인 진행 및 액세스 토큰 획득
  Future<String?> getGoogleAccessToken();

  /// 서버에 액세스 토큰 전송 및 JWT 획득
  Future<AuthResponse> authenticateWithGoogle(String accessToken);

  /// 회원가입 완료 후 토큰 획득
  Future<AuthResponse> completeSignUp(Map<String, dynamic> userData);

  /// 로그아웃
  Future<void> signOut();

  /// 로그인 상태 확인
  Future<bool> isLoggedIn();
}
