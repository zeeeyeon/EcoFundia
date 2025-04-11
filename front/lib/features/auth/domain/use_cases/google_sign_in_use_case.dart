import 'package:front/features/auth/domain/entities/auth_result_entity.dart';
import 'package:front/features/auth/domain/repositories/auth_repository.dart';

/// Google 로그인 UseCase
class GoogleSignInUseCase {
  final AuthRepository _repository;

  const GoogleSignInUseCase(this._repository);

  Future<AuthResultEntity> execute() async {
    return await _repository.signInWithGoogle();
  }
}
