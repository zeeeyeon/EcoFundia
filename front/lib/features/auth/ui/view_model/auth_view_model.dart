import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/auth/domain/models/auth_state.dart';
import 'package:front/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/features/auth/domain/models/auth_response.dart';

/// 인증 ViewModel
///
/// 인증 상태를 관리하고 UseCase들을 실행합니다.
class AuthViewModel extends StateNotifier<AuthState> {
  final GoogleSignInUseCase _googleSignInUseCase;
  final CompleteSignUpUseCase _completeSignUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final CheckLoginStatusUseCase _checkLoginStatusUseCase;

  AuthViewModel({
    required GoogleSignInUseCase googleSignInUseCase,
    required CompleteSignUpUseCase completeSignUpUseCase,
    required SignOutUseCase signOutUseCase,
    required CheckLoginStatusUseCase checkLoginStatusUseCase,
  })  : _googleSignInUseCase = googleSignInUseCase,
        _completeSignUpUseCase = completeSignUpUseCase,
        _signOutUseCase = signOutUseCase,
        _checkLoginStatusUseCase = checkLoginStatusUseCase,
        super(AuthState.initial()) {
    // 앱 시작 시 로그인 상태 확인
    LoggerUtil.i('🏗️ AuthViewModel 초기화');
    checkLoginStatus();
  }

  /// 로그인 상태 확인
  Future<void> checkLoginStatus() async {
    LoggerUtil.i('🔍 ViewModel - 로그인 상태 확인 시작');
    state = state.copyWithLoading();

    try {
      final isLoggedIn = await _checkLoginStatusUseCase.execute();
      LoggerUtil.i('✅ ViewModel - 로그인 상태 확인 완료: $isLoggedIn');
      state = state.copyWith(
        isLoggedIn: isLoggedIn,
        isLoading: false,
        error: null, // 에러 상태 초기화
      );
    } catch (e) {
      LoggerUtil.e('❌ ViewModel - 로그인 상태 확인 중 오류', e);
      state = state.copyWith(
        isLoggedIn: false,
        isLoading: false,
        error: '로그인 상태 확인 중 오류가 발생했습니다.',
      );
    }
  }

  /// Google 로그인 진행
  Future<void> signInWithGoogle() async {
    LoggerUtil.i('🔑 ViewModel - Google 로그인 시작');
    state = state.copyWithLoading();

    try {
      final result = await _googleSignInUseCase.execute();

      LoggerUtil.i('🔄 ViewModel - Google 로그인 결과 처리');
      switch (result) {
        case AuthSuccess(:final response):
          LoggerUtil.i('✅ ViewModel - 로그인 성공, isNewUser=${response.isNewUser}');

          if (response.isNewUser) {
            // 신규 사용자인 경우
            state = state.copyWith(
              isNewUser: true,
              isLoading: false,
              error: null,
            );
          } else {
            // 기존 사용자인 경우
            await _handleSuccessfulLogin(response);
          }

        case AuthError(:final message):
          LoggerUtil.e('❌ ViewModel - 로그인 오류: $message');
          state = state.copyWith(
            isLoading: false,
            error: message,
          );

        case AuthCancelled():
          LoggerUtil.w('⚠️ ViewModel - 로그인 취소됨');
          state = state.copyWith(
            isLoading: false,
            error: null,
          );
      }
    } catch (e) {
      LoggerUtil.e('❌ ViewModel - 예기치 않은 오류', e);
      state = state.copyWith(
        isLoading: false,
        error: '로그인 중 오류가 발생했습니다.',
      );
    }
  }

  /// 로그인 성공 시 처리
  Future<void> _handleSuccessfulLogin(AuthResponse response) async {
    try {
      // 토큰 저장
      if (response.token != null) {
        await StorageService.saveToken(response.token!);
      }

      // 리프레시 토큰 저장
      if (response.refreshToken != null) {
        await StorageService.saveRefreshToken(response.refreshToken!);
      }

      // 사용자 ID 저장
      if (response.userId != null) {
        await StorageService.saveUserId(response.userId!);
      }

      // 자동 로그인 활성화
      await StorageService.setAutoLogin(true);

      // 마지막 로그인 시간 업데이트
      await StorageService.updateLastLoginDate();

      state = state.copyWith(
        isLoggedIn: true,
        isNewUser: false,
        isLoading: false,
        error: null,
      );

      LoggerUtil.i('✅ ViewModel - 로그인 후처리 완료');
    } catch (e) {
      LoggerUtil.e('❌ ViewModel - 로그인 후처리 중 오류 발생', e);
      state = state.copyWith(
        isLoading: false,
        error: '로그인 처리 중 오류가 발생했습니다.',
      );
    }
  }

  /// 회원가입 완료
  Future<void> completeSignUp(Map<String, dynamic> userData) async {
    LoggerUtil.i('📝 ViewModel - 회원가입 완료 처리 시작');
    state = state.copyWithLoading();

    try {
      final result = await _completeSignUpUseCase.execute(userData);

      switch (result) {
        case AuthSuccess(:final response):
          LoggerUtil.i('✅ ViewModel - 회원가입 성공');
          await _handleSuccessfulLogin(response); // 로그인 처리 재사용

        case AuthError(:final message):
          LoggerUtil.e('❌ ViewModel - 회원가입 오류: $message');
          state = state.copyWith(
            isLoading: false,
            error: message,
          );

        case AuthCancelled():
          LoggerUtil.w('⚠️ ViewModel - 회원가입 취소됨');
          state = state.copyWith(
            isLoading: false,
            error: null,
          );
      }
    } catch (e) {
      LoggerUtil.e('❌ ViewModel - 회원가입 중 예기치 않은 오류', e);
      state = state.copyWith(
        isLoading: false,
        error: '회원가입 중 오류가 발생했습니다.',
      );
    }
  }

  /// 로그아웃
  Future<void> signOut({bool keepUserPreferences = false}) async {
    LoggerUtil.i('🚪 ViewModel - 로그아웃 시작');
    state = state.copyWithLoading();

    try {
      await _signOutUseCase.execute(); // SignOutUseCase 실행

      // 자동 로그인 비활성화
      await StorageService.setAutoLogin(false);

      // 선택적 데이터 유지 로그아웃
      await StorageService.secureLogout(
          keepUserPreferences: keepUserPreferences);

      state = state.copyWith(
        isLoggedIn: false,
        isNewUser: false,
        isLoading: false,
        error: null,
      );

      LoggerUtil.i('✅ ViewModel - 로그아웃 성공');
    } catch (e) {
      LoggerUtil.e('❌ ViewModel - 로그아웃 실패', e);
      state = state.copyWith(
        isLoading: false,
        error: '로그아웃 중 오류가 발생했습니다.',
      );
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    LoggerUtil.i('🧹 ViewModel - 에러 메시지 초기화');
    state = state.copyWith(error: null);
  }

  /// 상태 초기화 (페이지 전환 시 호출)
  void resetState() {
    LoggerUtil.i('🔄 ViewModel - 상태 초기화');
    state = AuthState.initial();
  }
}
