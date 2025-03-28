import 'package:front/features/auth/domain/entities/auth_result_entity.dart';
import 'package:front/features/auth/domain/entities/sign_up_entity.dart';
import 'package:front/features/auth/data/models/auth_response_model.dart';

/// 인증 관련 작업을 처리하는 저장소 인터페이스
/// 도메인 계층에서는 도메인 엔티티만 사용
abstract class AuthRepository {
  /// Google 로그인 처리 (통합 프로세스)
  Future<AuthResultEntity> signInWithGoogle();

  /// 회원가입 정보 전송 및 완료
  Future<AuthResultEntity> completeSignUp(SignUpEntity signUpData);

  /// 로그아웃
  Future<void> signOut();

  /// 로그인 상태 확인
  Future<bool> isLoggedIn();

  /// Google 사용자 정보 획득
  Future<Map<String, dynamic>?> getGoogleUserInfo();

  /// 토큰 갱신
  Future<AuthResponseModel> refreshToken(String refreshToken);
}
