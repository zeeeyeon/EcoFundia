import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/features/auth/domain/models/auth_result.dart';
import 'package:front/features/auth/domain/use_cases/check_login_status_use_case.dart';
import 'package:front/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/features/auth/domain/models/auth_response.dart';
import 'package:flutter/scheduler.dart';

/// 인증 ViewModel
///
/// 인증 상태를 관리하고 UseCase들을 실행합니다.
class AuthViewModel extends StateNotifier<bool> {
  final GoogleSignInUseCase _googleSignInUseCase;
  final CheckLoginStatusUseCase _checkLoginStatusUseCase;
  final AppStateViewModel _appStateViewModel;

  // 마지막으로 획득한 사용자 정보 (회원가입 시 사용)
  Map<String, dynamic>? _lastUserInfo;

  // 마지막으로 획득한 Google 액세스 토큰 (회원가입 시 사용)
  String? _lastAccessToken;

  // 초기화 상태 플래그
  bool _isInitialized = false;

  AuthViewModel({
    required GoogleSignInUseCase googleSignInUseCase,
    required CheckLoginStatusUseCase checkLoginStatusUseCase,
    required AppStateViewModel appStateViewModel,
  })  : _googleSignInUseCase = googleSignInUseCase,
        _checkLoginStatusUseCase = checkLoginStatusUseCase,
        _appStateViewModel = appStateViewModel,
        super(false) {
    // 프레임 렌더링 후에 로그인 상태 확인을 수행하여 Provider 초기화 충돌 방지
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true;
        _checkLoginStatus();
      }
    });
  }

  /// 로그인 상태 확인
  Future<void> _checkLoginStatus() async {
    _appStateViewModel.setLoading(true);

    try {
      final isLoggedIn = await _checkLoginStatusUseCase.execute();
      state = isLoggedIn;
    } catch (e) {
      LoggerUtil.e('로그인 상태 확인 실패', e);
      _appStateViewModel.setError('로그인 상태 확인 중 오류가 발생했습니다.');
      state = false;
    } finally {
      _appStateViewModel.setLoading(false);
    }
  }

  /// Google 로그인 진행
  Future<AuthResult> signInWithGoogle() async {
    try {
      _appStateViewModel.setLoading(true);
      _appStateViewModel.clearError();

      final result = await _googleSignInUseCase.execute();

      if (result is AuthSuccess) {
        await handleSuccessfulLogin(result.response);
        return result;
      } else if (result is AuthNewUser) {
        final accessToken = await _googleSignInUseCase.getAccessToken();
        if (accessToken != null) {
          _lastAccessToken = accessToken;
        }
        return result;
      } else if (result is AuthError) {
        LoggerUtil.e('로그인 실패: ${result.message}');
        _appStateViewModel.setError(result.message);
        return result;
      } else {
        return result;
      }
    } catch (e) {
      LoggerUtil.e('로그인 실패', e);
      _appStateViewModel.setError('로그인 중 오류가 발생했습니다.');
      return const AuthError('로그인 중 오류가 발생했습니다.');
    } finally {
      _appStateViewModel.setLoading(false);
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

      // 마지막 로그인 시간 업데이트
      await StorageService.updateLastLoginDate();

      state = true;
    } catch (e) {
      LoggerUtil.e('로그인 처리 실패', e);
      _appStateViewModel.setError('로그인 처리 중 오류가 발생했습니다.');
    }
  }

  /// 로그아웃
  Future<bool> signOut({bool keepUserPreferences = false}) async {
    try {
      _appStateViewModel.setLoading(true);
      await StorageService.secureLogout(
          keepUserPreferences: keepUserPreferences);
      _lastAccessToken = null;

      state = false;
      return true;
    } catch (e) {
      _appStateViewModel.setError('로그아웃 중 오류가 발생했습니다.');
      return false;
    } finally {
      _appStateViewModel.setLoading(false);
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    _appStateViewModel.clearError();
  }

  /// 상태 초기화 (페이지 전환 시 호출)
  void resetState() {
    state = false;
    _appStateViewModel.resetState();
  }

  /// 마지막으로 획득한 사용자 정보 반환
  /// 신규 사용자 회원가입 시 활용
  Future<Map<String, dynamic>> getLastUserInfo() async {
    Map<String, dynamic> userData =
        Map<String, dynamic>.from(_lastUserInfo ?? {});

    if (_lastAccessToken == null) {
      final accessToken = await _googleSignInUseCase.getAccessToken();
      if (accessToken != null) {
        _lastAccessToken = accessToken;
      }
    }

    if (_lastAccessToken != null) {
      userData['token'] = _lastAccessToken;
    }

    if (userData.isEmpty || userData.length == 1) {
      try {
        final googleUserInfo = await _googleSignInUseCase.getUserInfo() ?? {};
        userData.addAll(googleUserInfo);
      } catch (e) {
        LoggerUtil.e('사용자 정보 획득 실패', e);
        _appStateViewModel.setError('사용자 정보를 가져오는데 실패했습니다.');
      }
    }

    return userData;
  }

  /// 로그인 상태 업데이트
  void updateLoginState(bool isLoggedIn) {
    state = isLoggedIn;
    LoggerUtil.d('로그인 상태 업데이트: $isLoggedIn');
  }
}
