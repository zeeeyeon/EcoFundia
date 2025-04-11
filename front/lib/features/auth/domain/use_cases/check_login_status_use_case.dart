import 'package:front/features/auth/domain/repositories/auth_repository.dart';

/// 로그인 상태 확인 UseCase
class CheckLoginStatusUseCase {
  final AuthRepository _repository;

  const CheckLoginStatusUseCase(this._repository);

  Future<bool> execute() async {
    return await _repository.isLoggedIn();
  }
}
