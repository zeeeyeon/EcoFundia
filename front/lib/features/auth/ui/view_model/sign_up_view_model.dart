import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/exceptions/auth_exception.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/features/auth/domain/entities/sign_up_entity.dart';
import 'package:front/features/auth/domain/models/auth_response.dart';
import 'package:front/features/auth/domain/models/auth_result.dart';
import 'package:front/features/auth/domain/use_cases/complete_sign_up_use_case.dart';
import 'package:front/features/auth/ui/view_model/auth_provider.dart';
import 'package:front/features/auth/ui/view_model/auth_view_model.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/utils/sign_up_validator.dart';

class SignUpViewModel extends StateNotifier<bool> {
  final CompleteSignUpUseCase _completeSignUpUseCase;
  final AuthViewModel _authViewModel;
  final AppStateViewModel _appStateViewModel;

  SignUpViewModel({
    required CompleteSignUpUseCase completeSignUpUseCase,
    required AuthViewModel authViewModel,
    required AppStateViewModel appStateViewModel,
  })  : _completeSignUpUseCase = completeSignUpUseCase,
        _authViewModel = authViewModel,
        _appStateViewModel = appStateViewModel,
        super(false);

  Future<AuthResult> signUp({
    required String email,
    required String nickname,
    required String gender,
    required String age,
    String? token,
  }) async {
    LoggerUtil.i('📝 SignUpViewModel - 회원가입 시작');
    _appStateViewModel.setLoading(true);

    try {
      // 중앙화된 Validator를 사용하여 입력값 검증
      SignUpValidator.validateSignUpInput(
          email: email,
          nickname: nickname,
          gender: gender,
          age: age,
          token: token);

      // 나이 변환
      final parsedAge = int.parse(age);

      // 성별 변환 - UI의 '남성'/'여성'을 'MALE'/'FEMALE'로 변환
      final mappedGender = SignUpValidator.mapGenderToServer(gender);

      // SignUpEntity 생성
      final signUpEntity = SignUpEntity(
        email: email,
        nickname: nickname,
        gender: mappedGender,
        age: parsedAge,
        token: token,
      );

      final result = await _completeSignUpUseCase.execute(signUpEntity);

      if (result is AuthSuccess) {
        await _handleSuccessfulSignUp(result.response);
        return result;
      } else if (result is AuthError) {
        LoggerUtil.e('회원가입 실패: ${result.message}');
        _handleSignUpError(result.message);
        return result;
      } else if (result is AuthCancelled) {
        return result;
      } else {
        _handleSignUpError('회원가입 처리 중 오류가 발생했습니다.');
        return const AuthResult.error('회원가입 처리 중 오류가 발생했습니다.');
      }
    } catch (e) {
      LoggerUtil.e('회원가입 실패', e);
      final errorMessage =
          e is ValidationException ? e.message : '회원가입 중 오류가 발생했습니다.';
      _handleSignUpError(errorMessage);
      return AuthResult.error(errorMessage);
    } finally {
      _appStateViewModel.setLoading(false);
    }
  }

  Future<void> _handleSuccessfulSignUp(AuthResponse response) async {
    try {
      await _authViewModel.handleSuccessfulLogin(response);
      state = true;
    } catch (e) {
      LoggerUtil.e('회원가입 처리 실패', e);
      _handleSignUpError('회원가입 처리 중 오류가 발생했습니다.');
    }
  }

  void _handleSignUpError(String message) {
    _appStateViewModel.setError(message);
  }

  void clearError() {
    _appStateViewModel.clearError();
  }
}

/// SignUpViewModel Provider
final signUpProvider = StateNotifierProvider<SignUpViewModel, bool>((ref) {
  final completeSignUpUseCase = ref.watch(completeSignUpUseCaseProvider);
  final authViewModel = ref.watch(authProvider.notifier);
  final appStateViewModel = ref.watch(appStateProvider.notifier);
  return SignUpViewModel(
    completeSignUpUseCase: completeSignUpUseCase,
    authViewModel: authViewModel,
    appStateViewModel: appStateViewModel,
  );
});
