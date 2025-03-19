import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/auth/domain/models/auth_response.dart';
import 'package:front/features/auth/domain/models/auth_state.dart';
import 'package:front/features/auth/domain/models/auth_result.dart';
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
      // Form에서 이미 유효성 검사를 했으므로, 안전하게 int로 변환
      final userData = {
        'token': token, // 구글에서 받아온 토큰
        'nickname': nickname,
        'gender': gender == '남성'
            ? 'MALE'
            : 'FEMALE', // UI의 '남성'/'여성'을 'MALE'/'FEMALE'로 변환
        'age': int.parse(age),
      };

      // 토큰 정보 검증
      if (token == null || token.isEmpty) {
        LoggerUtil.w('⚠️ 회원가입 데이터에 토큰이 없습니다. 회원가입이 실패할 수 있습니다.');
        throw Exception('인증 토큰이 없습니다.');
      }

      LoggerUtil.i('📤 회원가입 데이터: $userData');
      final result = await _completeSignUpUseCase.execute(userData);

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
      _handleSignUpError('회원가입 중 오류가 발생했습니다.');
      return const AuthResult.error('회원가입 중 오류가 발생했습니다.');
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
