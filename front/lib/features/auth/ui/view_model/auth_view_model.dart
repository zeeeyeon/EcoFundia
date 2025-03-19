import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/auth/domain/models/auth_state.dart';
import 'package:front/features/auth/domain/models/auth_result.dart';
import 'package:front/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/features/auth/domain/models/auth_response.dart';

/// 인증 ViewModel
///
/// 인증 상태를 관리하고 UseCase들을 실행합니다.
class AuthViewModel extends StateNotifier<AuthState> {
  final GoogleSignInUseCase _googleSignInUseCase;
  final SignOutUseCase _signOutUseCase;
  final CheckLoginStatusUseCase _checkLoginStatusUseCase;

  // 마지막으로 획득한 사용자 정보 (회원가입 시 사용)
  Map<String, dynamic>? _lastUserInfo;

  // 마지막으로 획득한 Google 액세스 토큰 (회원가입 시 사용)
  String? _lastAccessToken;

  AuthViewModel({
    required GoogleSignInUseCase googleSignInUseCase,
    required SignOutUseCase signOutUseCase,
    required CheckLoginStatusUseCase checkLoginStatusUseCase,
  })  : _googleSignInUseCase = googleSignInUseCase,
        _signOutUseCase = signOutUseCase,
        _checkLoginStatusUseCase = checkLoginStatusUseCase,
        super(AuthState.initial()) {
    // 앱 시작 시 로그인 상태 확인
    LoggerUtil.i('🏗️ AuthViewModel 초기화');
    _checkLoginStatus();
  }

  /// 로그인 상태 확인
  Future<void> _checkLoginStatus() async {
    LoggerUtil.i('🔍 ViewModel - 로그인 상태 확인 시작');
    state = state.copyWithLoading();

    try {
      final isLoggedIn = await StorageService.hasValidToken();
      LoggerUtil.i('✅ ViewModel - 로그인 상태 확인 완료: $isLoggedIn');
      state = state.copyWith(
        isLoggedIn: isLoggedIn,
        isLoading: false,
        error: null,
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
  Future<AuthResult> signInWithGoogle() async {
    try {
      LoggerUtil.i('🔑 ViewModel - Google 로그인 시작');
      state = state.copyWithLoading();
      clearError();

      final result = await _googleSignInUseCase.execute();
      LoggerUtil.i('🔄 ViewModel - Google 로그인 결과 처리');

      if (result is AuthSuccess) {
        LoggerUtil.i('✅ ViewModel - 로그인 성공');
        await handleSuccessfulLogin(result.response);
        return result;
      } else if (result is AuthNewUser) {
        LoggerUtil.i('📝 ViewModel - 신규 사용자 감지');
        // 신규 사용자의 경우 액세스 토큰 저장
        final accessToken = await _googleSignInUseCase.getAccessToken();
        if (accessToken != null) {
          _lastAccessToken = accessToken;
          LoggerUtil.i('✅ ViewModel - 신규 사용자 액세스 토큰 저장됨');
        } else {
          LoggerUtil.w('⚠️ ViewModel - 신규 사용자 액세스 토큰 획득 실패');
        }
        return result;
      } else if (result is AuthError) {
        LoggerUtil.e('⛔ ViewModel - 로그인 오류: ${result.message}');
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
        return result;
      } else {
        LoggerUtil.w('⚠️ ViewModel - 로그인 취소됨');
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
        return result;
      }
    } catch (e) {
      LoggerUtil.e('❌ ViewModel - 예상치 못한 오류 발생', e);
      state = state.copyWith(
        isLoading: false,
        error: '로그인 중 오류가 발생했습니다.',
      );
      return const AuthError('로그인 중 오류가 발생했습니다.');
    }
  }

  /// 로그인 성공 시 처리
  Future<void> handleSuccessfulLogin(AuthResponse response) async {
    try {
      // 토큰 저장
      if (response.accessToken != null) {
        await StorageService.saveToken(response.accessToken!);
      }

      // 리프레시 토큰 저장
      if (response.refreshToken != null) {
        await StorageService.saveRefreshToken(response.refreshToken!);
      }

      // 사용자 정보 저장
      if (response.user != null) {
        await StorageService.saveUserId(response.user!.userId.toString());
        await StorageService.saveUserEmail(response.user!.email);
        await StorageService.saveUserNickname(response.user!.nickname);
      }

      // 자동 로그인 활성화
      await StorageService.setAutoLogin(true);

      // 마지막 로그인 시간 업데이트
      await StorageService.updateLastLoginDate();

      state = state.copyWith(
        isLoggedIn: true,
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

  /// 로그아웃
  Future<bool> signOut({bool keepUserPreferences = false}) async {
    LoggerUtil.i('🚪 ViewModel - 로그아웃 시작');
    state = state.copyWithLoading();

    try {
      await _signOutUseCase.execute();

      // 자동 로그인 비활성화
      await StorageService.setAutoLogin(false);

      // 선택적 데이터 유지 로그아웃
      await StorageService.secureLogout(
          keepUserPreferences: keepUserPreferences);

      // 임시 저장된 액세스 토큰 삭제
      _lastAccessToken = null;

      state = state.copyWith(
        isLoggedIn: false,
        isLoading: false,
        error: null,
      );

      LoggerUtil.i('✅ ViewModel - 로그아웃 성공');
      return true;
    } catch (e) {
      LoggerUtil.e('❌ ViewModel - 로그아웃 실패', e);
      state = state.copyWith(
        isLoading: false,
        error: '로그아웃 중 오류가 발생했습니다.',
      );
      return false;
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

  /// 마지막으로 획득한 사용자 정보 반환
  /// 신규 사용자 회원가입 시 활용
  Future<Map<String, dynamic>> getLastUserInfo() async {
    LoggerUtil.i('🔍 ViewModel - 마지막 사용자 정보 요청');
    Map<String, dynamic> userData =
        Map<String, dynamic>.from(_lastUserInfo ?? {});

    // 액세스 토큰이 없으면 다시 시도
    if (_lastAccessToken == null) {
      LoggerUtil.w('⚠️ ViewModel - 저장된 액세스 토큰이 없습니다. 다시 시도합니다.');
      final accessToken = await _googleSignInUseCase.getAccessToken();
      if (accessToken != null) {
        _lastAccessToken = accessToken;
        LoggerUtil.i('✅ ViewModel - 액세스 토큰 획득 성공');
      } else {
        LoggerUtil.e('❌ ViewModel - 액세스 토큰 획득 실패');
      }
    }

    // 액세스 토큰 추가
    if (_lastAccessToken != null) {
      userData['token'] = _lastAccessToken;
      LoggerUtil.i('✅ ViewModel - 사용자 정보에 액세스 토큰 추가됨');
    } else {
      LoggerUtil.w('⚠️ ViewModel - 액세스 토큰이 없습니다. 회원가입이 실패할 수 있습니다.');
    }

    // 이미 저장된 정보가 없으면 Google SignIn에서 다시 시도
    if (userData.isEmpty || userData.length == 1) {
      // 토큰만 있는 경우
      try {
        final googleUserInfo = await _googleSignInUseCase.getUserInfo() ?? {};
        userData.addAll(googleUserInfo);
      } catch (e) {
        LoggerUtil.e('❌ ViewModel - 사용자 정보 획득 중 오류', e);
      }
    }

    LoggerUtil.i('✅ ViewModel - 사용자 정보 반환: ${userData.keys}');
    return userData;
  }
}
