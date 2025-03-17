import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/auth/domain/models/auth_state.dart';
import 'package:front/features/auth/domain/repositories/auth_repository.dart';

/// 인증 상태 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState.initial()) {
    // 앱 시작 시 로그인 상태 확인
    checkLoginStatus();
  }

  /// 로그인 상태 확인
  Future<void> checkLoginStatus() async {
    state = state.copyWithLoading();

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      state = state.copyWith(isLoggedIn: isLoggedIn, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoggedIn: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Google 로그인 진행
  Future<void> signInWithGoogle() async {
    state = state.copyWithLoading();

    try {
      // 1. Google 로그인으로 인가 코득
      final authCode = await _authRepository.getGoogleAuthCode();

      if (authCode == null) {
        // 사용자가 로그인을 취소한 경우
        state = state.copyWith(isLoading: false);
        return;
      }

      // 2. 인가 코득로 서버 인증 진행
      final authResponse =
          await _authRepository.authenticateWithGoogle(authCode);

      // 3. 응답에 따라 상태 업데이트
      state = state.copyWith(
        isLoggedIn: !authResponse.isNewUser, // 기존 회원이면 로그인 상태로
        isNewUser: authResponse.isNewUser, // 신규 회원 여부
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 회원가입 완료
  Future<void> completeSignUp(Map<String, dynamic> userData) async {
    state = state.copyWithLoading();

    try {
      final authResponse = await _authRepository.completeSignUp(userData);

      state = state.copyWith(
        isLoggedIn: true,
        isNewUser: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    state = state.copyWithLoading();

    try {
      await _authRepository.signOut();

      state = state.copyWith(
        isLoggedIn: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }
}
