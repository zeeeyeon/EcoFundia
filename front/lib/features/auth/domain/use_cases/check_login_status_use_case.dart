import 'package:front/features/auth/domain/repositories/auth_repository.dart';
import 'package:front/utils/logger_util.dart';

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
