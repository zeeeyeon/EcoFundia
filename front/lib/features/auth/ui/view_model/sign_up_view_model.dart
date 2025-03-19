import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/exceptions/auth_exception.dart';
import 'package:front/features/auth/domain/entities/sign_up_entity.dart';
import 'package:front/features/auth/domain/models/auth_response.dart';
import 'package:front/features/auth/domain/models/auth_state.dart';
import 'package:front/features/auth/domain/models/auth_result.dart';
import 'package:front/features/auth/domain/use_cases/complete_sign_up_use_case.dart';
import 'package:front/features/auth/ui/view_model/auth_provider.dart';
import 'package:front/features/auth/ui/view_model/auth_view_model.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/utils/sign_up_validator.dart';

class SignUpViewModel extends StateNotifier<AuthState> {
  final CompleteSignUpUseCase _completeSignUpUseCase;
  final AuthViewModel _authViewModel;

  SignUpViewModel({
    required CompleteSignUpUseCase completeSignUpUseCase,
    required AuthViewModel authViewModel,
  })  : _completeSignUpUseCase = completeSignUpUseCase,
        _authViewModel = authViewModel,
        super(AuthState.initial());

  Future<AuthResult> signUp({
    required String email,
    required String nickname,
    required String gender,
    required String age,
    String? token,
  }) async {
    LoggerUtil.i('📝 SignUpViewModel - 회원가입 시작');
    state = state.copyWithLoading();

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

      LoggerUtil.i('📤 회원가입 데이터: $signUpEntity');
      final result = await _completeSignUpUseCase.execute(signUpEntity);

      if (result is AuthSuccess) {
        LoggerUtil.i('✅ 회원가입 성공');
        await _handleSuccessfulSignUp(result.response);
        return result;
      } else if (result is AuthError) {
        LoggerUtil.e('❌ 회원가입 실패: ${result.message}');
        _handleSignUpError(result.message);
        return result;
      } else if (result is AuthCancelled) {
        LoggerUtil.w('⚠️ 회원가입 취소됨');
        state = state.copyWith(isLoading: false);
        return result;
      } else {
        LoggerUtil.e('❌ 회원가입 처리 중 알 수 없는 오류 발생');
        _handleSignUpError('회원가입 처리 중 오류가 발생했습니다.');
        return const AuthResult.error('회원가입 처리 중 오류가 발생했습니다.');
      }
    } catch (e) {
      LoggerUtil.e('❌ 회원가입 중 오류 발생', e);
      final errorMessage =
          e is ValidationException ? e.message : '회원가입 중 오류가 발생했습니다.';
      _handleSignUpError(errorMessage);
      return AuthResult.error(errorMessage);
    }
  }

  Future<void> _handleSuccessfulSignUp(AuthResponse response) async {
    try {
      await _authViewModel.handleSuccessfulLogin(response);
      state = state.copyWith(
        isLoggedIn: true,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      LoggerUtil.e('❌ 회원가입 후처리 중 오류 발생', e);
      _handleSignUpError('회원가입 처리 중 오류가 발생했습니다.');
    }
  }

  void _handleSignUpError(String message) {
    state = state.copyWith(
      isLoading: false,
      error: message,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// SignUpViewModel Provider
final signUpProvider = StateNotifierProvider<SignUpViewModel, AuthState>((ref) {
  final completeSignUpUseCase = ref.watch(completeSignUpUseCaseProvider);
  final authViewModel = ref.watch(authProvider.notifier);
  return SignUpViewModel(
    completeSignUpUseCase: completeSignUpUseCase,
    authViewModel: authViewModel,
  );
});
