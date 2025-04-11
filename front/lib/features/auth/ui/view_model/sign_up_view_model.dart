import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/exceptions/auth_exception.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/features/auth/domain/entities/sign_up_entity.dart';
import 'package:front/features/auth/domain/entities/auth_result_entity.dart';
import 'package:front/features/auth/domain/use_cases/complete_sign_up_use_case.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/utils/sign_up_validator.dart';
import 'package:front/features/auth/providers/auth_providers.dart';

/// 회원가입 관련 ViewModel
class SignUpViewModel extends StateNotifier<bool> {
  final CompleteSignUpUseCase _completeSignUpUseCase;
  final AppStateViewModel _appStateViewModel;

  SignUpViewModel({
    required CompleteSignUpUseCase completeSignUpUseCase,
    required AppStateViewModel appStateViewModel,
  })  : _completeSignUpUseCase = completeSignUpUseCase,
        _appStateViewModel = appStateViewModel,
        super(false);

  /// 회원가입 처리
  Future<AuthResultEntity> signUp({
    required String email,
    required String nickname,
    required String gender,
    required int age,
    String? token,
  }) async {
    try {
      _appStateViewModel.setLoading(true);
      _appStateViewModel.clearError();

      // 입력 유효성 검사
      final validationResult = SignUpValidator.validate(
        email: email,
        nickname: nickname,
        gender: gender,
        age: age,
      );

      if (!validationResult.isValid) {
        return AuthResultEntity.error(
            validationResult.errorMessage ?? '입력 값이 올바르지 않습니다.');
      }

      // 회원가입 데이터 생성
      final signUpData = SignUpEntity(
        nickname: nickname,
        gender: gender,
        age: age,
        token: token,
      );

      // UseCase 실행
      final result = await _completeSignUpUseCase.execute(signUpData);

      if (result is AuthSuccessEntity) {
        state = true;
      }

      return result;
    } catch (e) {
      LoggerUtil.e('회원가입 처리 중 오류', e);

      String errorMessage = '회원가입 처리 중 오류가 발생했습니다.';
      if (e is AuthException) {
        errorMessage = e.message;
      }

      _appStateViewModel.setError(errorMessage);
      return AuthResultEntity.error(errorMessage);
    } finally {
      _appStateViewModel.setLoading(false);
    }
  }
}

/// SignUpViewModel Provider
final signUpProvider = StateNotifierProvider<SignUpViewModel, bool>((ref) {
  final completeSignUpUseCase = ref.watch(completeSignUpUseCaseProvider);
  final appStateViewModel = ref.watch(appStateProvider.notifier);
  return SignUpViewModel(
    completeSignUpUseCase: completeSignUpUseCase,
    appStateViewModel: appStateViewModel,
  );
});
