import 'package:front/features/auth/domain/entities/auth_result_entity.dart';
import 'package:front/features/auth/domain/repositories/auth_repository.dart';

/// Google 로그인 진행 UseCase
class GoogleSignInUseCase {
  final AuthRepository _repository;

  GoogleSignInUseCase(this._repository);

  /// Google 로그인 실행
  ///
  /// 반환값:
  /// - AuthResultEntity.success: 로그인 성공
  /// - AuthResultEntity.newUser: 신규 사용자 (회원가입 필요)
  /// - AuthResultEntity.error: 오류 발생
  /// - AuthResultEntity.cancelled: 로그인 취소됨
  Future<AuthResultEntity> execute() async {
    return await _repository.signInWithGoogle();
  }
}
