import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/auth/domain/models/auth_state.dart';
import 'package:front/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:front/features/auth/ui/view_model/auth_provider.dart';
import 'package:front/features/auth/ui/view_model/auth_view_model.dart';
import 'package:front/utils/logger_util.dart';

class SignUpViewModel extends StateNotifier<AuthState> {
  final CompleteSignUpUseCase _completeSignUpUseCase;
  final AuthViewModel _authViewModel;

  SignUpViewModel({
    required CompleteSignUpUseCase completeSignUpUseCase,
    required AuthViewModel authViewModel,
  })  : _completeSignUpUseCase = completeSignUpUseCase,
        _authViewModel = authViewModel,
        super(AuthState.initial());

  Future<AuthResult> completeSignUp({
    required String email,
    required String nickname,
    required String gender,
    required int age,
    String? serverAuthCode,
  }) async {
    LoggerUtil.i('📝 SignUpViewModel - 회원가입 시작');
    state = state.copyWithLoading();

    try {
      final userData = {
        'email': email,
        'nickname': nickname,
        'gender': gender,
        'age': age,
        'serverAuthCode': serverAuthCode,
      };

      LoggerUtil.i('📤 회원가입 데이터: $userData');
      final result = await _completeSignUpUseCase.execute(userData);

      switch (result) {
        case AuthSuccess(:final response):
          LoggerUtil.i('✅ 회원가입 성공');
          await _authViewModel.handleSuccessfulLogin(response);
          state = state.copyWith(
            isLoggedIn: true,
            isNewUser: false,
            isLoading: false,
          );
          return result;
        case AuthError():
          LoggerUtil.e('❌ 회원가입 실패: ${result.message}');
          state = state.copyWith(
            isLoading: false,
            error: result.message,
          );
          return result;
        case AuthCancelled():
          LoggerUtil.w('⚠️ 회원가입 취소됨');
          state = state.copyWith(isLoading: false);
          return result;
      }
    } catch (e) {
      LoggerUtil.e('❌ 회원가입 중 오류 발생', e);
      state = state.copyWith(
        isLoading: false,
        error: '회원가입 중 오류가 발생했습니다.',
      );
      return const AuthResult.error('회원가입 중 오류가 발생했습니다.');
    }
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
