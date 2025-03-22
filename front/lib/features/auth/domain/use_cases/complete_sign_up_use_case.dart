import 'package:front/features/auth/data/models/sign_up_model.dart';
import 'package:front/features/auth/domain/entities/sign_up_entity.dart';
import 'package:front/features/auth/domain/models/auth_result.dart';
import 'package:front/features/auth/domain/repositories/auth_repository.dart';
import 'package:front/core/exceptions/auth_exception.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/utils/sign_up_validator.dart';

/// 회원가입 완료 UseCase
class CompleteSignUpUseCase {
  final AuthRepository _authRepository;

  CompleteSignUpUseCase(this._authRepository);

  /// SignUpEntity를 이용한 회원가입 실행
  Future<AuthResult> execute(SignUpEntity signUpEntity) async {
    LoggerUtil.i('🚀 CompleteSignUpUseCase - 실행 시작');

    try {
      // 중앙화된 Validator를 사용하여 유효성 검증
      SignUpValidator.validateSignUpData(signUpEntity);

      // Entity를 Model로 변환
      final signUpModel = SignUpModel.fromEntity(signUpEntity);

      // Repository 호출
      final authResponse = await _authRepository.completeSignUp(signUpModel);
      LoggerUtil.i('✅ 회원가입 완료 성공');

      return AuthResult.success(authResponse);
    } catch (e) {
      LoggerUtil.e('❌ 회원가입 완료 중 오류', e);
      if (e is AuthException) {
        return AuthResult.error(e.message, statusCode: e.statusCode);
      }
      return AuthResult.error(e.toString());
    } finally {
      LoggerUtil.i('🏁 CompleteSignUpUseCase - 실행 종료');
    }
  }

  /// Map 형태의 데이터로 회원가입 실행 (이전 버전과의 호환성 유지)
  Future<AuthResult> executeWithMap(Map<String, dynamic> userData) async {
    LoggerUtil.i('🚀 CompleteSignUpUseCase - Map 데이터로 실행 시작');

    try {
      // 필수 필드 확인
      if (!userData.containsKey('email') ||
          !userData.containsKey('nickname') ||
          !userData.containsKey('gender') ||
          !userData.containsKey('age')) {
        throw AuthException('필수 회원정보가 누락되었습니다.');
      }

      // Map에서 Entity 생성
      final entity = SignUpEntity(
        email: userData['email'] as String,
        nickname: userData['nickname'] as String,
        gender: userData['gender'] as String,
        age: userData['age'] as int,
        token: userData['token'] as String?,
      );

      // 기존 execute 메서드 호출
      return await execute(entity);
    } catch (e) {
      LoggerUtil.e('❌ 회원가입 완료 중 오류', e);
      if (e is AuthException) {
        return AuthResult.error(e.message, statusCode: e.statusCode);
      }
      return AuthResult.error(e.toString());
    }
  }
}
