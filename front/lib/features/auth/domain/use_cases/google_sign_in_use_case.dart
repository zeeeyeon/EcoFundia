import 'package:front/features/auth/domain/models/auth_response.dart';
import 'package:front/features/auth/domain/repositories/auth_repository.dart';
import 'package:front/utils/logger_util.dart';

/// 구글 로그인 UseCase
///
/// 비즈니스 로직을 처리하고 저장소 계층에 데이터 작업을 위임합니다.
class GoogleSignInUseCase {
  final AuthRepository _authRepository;

  GoogleSignInUseCase(this._authRepository);

  /// 구글 로그인 실행
  ///
  /// 성공 시 AuthResponse 반환, 실패 시 예외 발생, 취소 시 null 반환
  Future<AuthResult> execute() async {
    LoggerUtil.i('🚀 GoogleSignInUseCase - 실행 시작');
    try {
      // 1. 구글 액세스 토큰 획득
      LoggerUtil.i('🔐 UseCase - 액세스 토큰 요청 중...');
      final accessToken = await _authRepository.getGoogleAccessToken();

      if (accessToken == null) {
        LoggerUtil.w('⚠️ UseCase - 액세스 토큰이 null (사용자 취소)');
        return const AuthResult.cancelled();
      }

      LoggerUtil.i(
          '🔑 UseCase - 액세스 토큰 획득 성공 (${LoggerUtil.safeToken(accessToken)})');

      // 2. 서버 인증 및 토큰 획득
      LoggerUtil.i('🔄 UseCase - 서버 인증 요청 중...');
      final authResponse =
          await _authRepository.authenticateWithGoogle(accessToken);
      LoggerUtil.i('✅ UseCase - 서버 인증 성공, isNewUser=${authResponse.isNewUser}');

      return AuthResult.success(authResponse);
    } catch (e) {
      LoggerUtil.e('❌ UseCase - 오류 발생', e);
      return AuthResult.error(e.toString());
    } finally {
      LoggerUtil.i('🏁 GoogleSignInUseCase - 실행 종료');
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
      final isLoggedIn = await _authRepository.isLoggedIn();
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

/// 인증 결과를 나타내는 sealed class
sealed class AuthResult {
  const AuthResult();

  const factory AuthResult.success(AuthResponse response) = AuthSuccess;
  const factory AuthResult.error(String message) = AuthError;
  const factory AuthResult.cancelled() = AuthCancelled;
}

class AuthSuccess extends AuthResult {
  final AuthResponse response;
  const AuthSuccess(this.response);
}

class AuthError extends AuthResult {
  final String message;
  const AuthError(this.message);
}

class AuthCancelled extends AuthResult {
  const AuthCancelled();
}
