import 'package:front/features/auth/domain/repositories/auth_repository.dart';
import 'package:front/utils/logger_util.dart';

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
