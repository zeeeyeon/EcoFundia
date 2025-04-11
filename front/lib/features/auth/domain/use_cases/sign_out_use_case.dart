import 'package:front/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

/// 로그아웃 UseCase
class SignOutUseCase {
  final AuthRepository _repository;

  const SignOutUseCase(this._repository);

  Future<void> execute({CancelToken? cancelToken}) async {
    await _repository.signOut(cancelToken: cancelToken);
  }
}
