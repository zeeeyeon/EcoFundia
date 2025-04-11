import 'package:front/features/auth/domain/entities/auth_result_entity.dart';
import 'package:front/features/auth/domain/entities/sign_up_entity.dart';
import 'package:front/features/auth/domain/repositories/auth_repository.dart';

/// 회원가입 완료 UseCase
class CompleteSignUpUseCase {
  final AuthRepository _repository;

  CompleteSignUpUseCase(this._repository);

  /// 회원가입 정보를 서버에 전송하고 결과를 반환
  ///
  /// 반환값:
  /// - AuthResultEntity.success: 회원가입 및 로그인 성공
  /// - AuthResultEntity.error: 오류 발생
  Future<AuthResultEntity> execute(SignUpEntity signUpData) async {
    return await _repository.completeSignUp(signUpData);
  }
}
