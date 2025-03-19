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

/// 회원가입 완료 UseCase
class CompleteSignUpUseCase {
  final AuthRepository _authRepository;

  CompleteSignUpUseCase(this._authRepository);

  Future<AuthResult> execute(Map<String, dynamic> userData) async {
    LoggerUtil.i('🚀 CompleteSignUpUseCase - 실행 시작');

    try {
      LoggerUtil.i('📝 회원가입 데이터: $userData');
      final authResponse = await _authRepository.completeSignUp(userData);
      LoggerUtil.i('✅ 회원가입 완료 성공');
      return AuthResult.success(authResponse);
    } catch (e) {
      LoggerUtil.e('❌ 회원가입 완료 중 오류', e);
      return AuthResult.error(e.toString());
    } finally {
      LoggerUtil.i('🏁 CompleteSignUpUseCase - 실행 종료');
    }
  }
}

/// 로그아웃 UseCase
class SignOutUseCase {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  Future<bool> execute() async {
    LoggerUtil.i('🚀 SignOutUseCase - 실행 시작');

    try {
      await _authRepository.signOut();
      LoggerUtil.i('✅ 로그아웃 성공');
      return true;
    } catch (e) {
      LoggerUtil.e('❌ 로그아웃 중 오류', e);
      return false;
    } finally {
      LoggerUtil.i('🏁 SignOutUseCase - 실행 종료');
    }
  }
}

/// 로그인 상태 확인 UseCase
class CheckLoginStatusUseCase {
  final AuthRepository _authRepository;

  CheckLoginStatusUseCase(this._authRepository);

  Future<bool> execute() async {
    LoggerUtil.i('🚀 CheckLoginStatusUseCase - 실행 시작');

    try {
      final isLoggedIn = await _authRepository.checkLoginStatus();
      LoggerUtil.i('ℹ️ 로그인 상태: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      LoggerUtil.e('❌ 로그인 상태 확인 중 오류', e);
      return false;
    } finally {
      LoggerUtil.i('🏁 CheckLoginStatusUseCase - 실행 종료');
    }
  }
}
