import '../models/auth_response.dart';
import 'package:front/features/auth/domain/models/auth_result.dart';
import 'package:front/features/auth/data/models/sign_up_model.dart';

/// 인증 관련 작업을 처리하는 저장소 인터페이스
abstract class AuthRepository {
  /// Google 로그인 진행 및 액세스 토큰 획득
  Future<String?> getGoogleAccessToken();

  /// 서버에 액세스 토큰 전송 및 JWT 획득
  Future<AuthResponse> authenticateWithGoogle(String accessToken);

  /// 회원가입 완료 후 토큰 획득 (SignUpModel 버전)
  Future<AuthResponse> completeSignUp(SignUpModel signUpData);

  /// 회원가입 완료 후 토큰 획득 (Map 버전 - 레거시 지원)
  Future<AuthResponse> completeSignUpWithMap(Map<String, dynamic> userData);

  /// 로그아웃
  Future<void> signOut();

  /// 로그인 상태 확인
  Future<bool> isLoggedIn();

  /// Google 로그인 처리
  Future<AuthResult> signInWithGoogle();

  /// 로그인 상태 확인
  Future<bool> checkLoginStatus();

  /// Google 사용자 정보 획득
  Future<Map<String, dynamic>?> getGoogleUserInfo();
}
