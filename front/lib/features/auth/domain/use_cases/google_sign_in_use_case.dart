import 'package:front/features/auth/domain/repositories/auth_repository.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/features/auth/domain/models/auth_result.dart';

/// 구글 로그인 UseCase
///
/// 비즈니스 로직을 처리하고 저장소 계층에 데이터 작업을 위임합니다.
class GoogleSignInUseCase {
  final AuthRepository _repository;

  GoogleSignInUseCase(this._repository);

  /// Google 액세스 토큰만 획득
  Future<String?> getAccessToken() async {
    LoggerUtil.i('🔑 UseCase - Google 액세스 토큰 요청');
    try {
      return await _repository.getGoogleAccessToken();
    } catch (e) {
      LoggerUtil.e('❌ UseCase - Google 액세스 토큰 획득 중 오류', e);
      return null;
    }
  }

  /// 이미 얻은 액세스 토큰으로 서버 인증 시도
  Future<AuthResult> authenticateWithToken(String accessToken) async {
    LoggerUtil.i('🔑 UseCase - 액세스 토큰으로 서버 인증 시도');
    try {
      try {
        final response = await _repository.authenticateWithGoogle(accessToken);
        LoggerUtil.i('✅ UseCase - 서버 인증 성공');
        return AuthResult.success(response);
      } catch (e) {
        if (e.toString().contains('404')) {
          LoggerUtil.i('ℹ️ UseCase - 신규 사용자 감지, 회원가입 필요');
          return const AuthResult.newUser('회원가입이 필요합니다.');
        }
        rethrow;
      }
    } catch (e) {
      LoggerUtil.e('❌ UseCase - 서버 인증 중 오류 발생', e);
      return AuthResult.error(e.toString());
    }
  }

  /// 구글 로그인 실행 (legacy 메서드)
  Future<AuthResult> execute() async {
    LoggerUtil.i('🔑 UseCase - Google 로그인 시작');
    try {
      final result = await _repository.signInWithGoogle();

      if (result is AuthError && result.statusCode == 404) {
        LoggerUtil.i('ℹ️ UseCase - 신규 사용자 감지, 회원가입 필요');
        return const AuthResult.newUser('회원가입이 필요합니다.');
      }

      LoggerUtil.i('✅ UseCase - Google 로그인 결과 처리 완료');
      return result;
    } catch (e) {
      LoggerUtil.e('❌ UseCase - Google 로그인 중 오류 발생', e);
      return const AuthResult.error('로그인 중 오류가 발생했습니다.');
    }
  }

  /// 구글 로그인 과정에서 획득한 사용자 기본 정보 조회
  /// email, name과 같은 기본 정보를 반환합니다.
  Future<Map<String, dynamic>?> getUserInfo() async {
    LoggerUtil.i('🔍 UseCase - 구글 사용자 정보 요청');
    try {
      return await _repository.getGoogleUserInfo();
    } catch (e) {
      LoggerUtil.e('❌ UseCase - 구글 사용자 정보 획득 중 오류', e);
      return null;
    }
  }
}
