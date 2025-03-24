import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/features/auth/domain/entities/auth_result_entity.dart';
import 'package:front/features/auth/domain/use_cases/check_login_status_use_case.dart';
import 'package:front/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:flutter/scheduler.dart';
import 'package:front/features/auth/domain/repositories/auth_repository.dart';

/// 인증 ViewModel
///
/// 인증 상태를 관리하고 UseCase들을 실행합니다.
class AuthViewModel extends StateNotifier<bool> {
  final GoogleSignInUseCase _googleSignInUseCase;
  final CheckLoginStatusUseCase _checkLoginStatusUseCase;
  final AppStateViewModel _appStateViewModel;
  final AuthRepository _authRepository;

  // 마지막으로 획득한 사용자 정보 (회원가입 시 사용)
  Map<String, dynamic>? _lastUserInfo;

  // 초기화 상태 플래그
  bool _isInitialized = false;

  AuthViewModel({
    required GoogleSignInUseCase googleSignInUseCase,
    required CheckLoginStatusUseCase checkLoginStatusUseCase,
    required AppStateViewModel appStateViewModel,
    required AuthRepository authRepository,
  })  : _googleSignInUseCase = googleSignInUseCase,
        _checkLoginStatusUseCase = checkLoginStatusUseCase,
        _appStateViewModel = appStateViewModel,
        _authRepository = authRepository,
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

  /// 사용자 세션 데이터 업데이트
  Future<void> _updateUserSessionData(
      String userId, String email, String nickname) async {
    await StorageService.saveUserId(userId);
    await StorageService.saveUserEmail(email);
    await StorageService.saveUserNickname(nickname);
  }

  /// Google 로그인 수행
  Future<AuthResultEntity> signInWithGoogle() async {
    try {
      _appStateViewModel.setLoading(true);
      _appStateViewModel.clearError();

      final result = await _authRepository.signInWithGoogle();

      // 결과에 따른 처리
      if (result is AuthSuccessEntity) {
        final successResult = result;
        LoggerUtil.i('✅ 로그인 성공: ${successResult.user.email}');
        // 사용자 데이터 저장
        await _updateUserSessionData(
          successResult.user.userId.toString(),
          successResult.user.email,
          successResult.user.nickname,
        );
        state = true;
      } else if (result is AuthNewUserEntity) {
        LoggerUtil.i('🔄 회원가입 필요: ${result.message}');
        // 구글 사용자 정보 획득
        _lastUserInfo = await _authRepository.getGoogleUserInfo();
        LoggerUtil.i('📝 회원가입용 Google 정보 획득: $_lastUserInfo');
      } else if (result is AuthErrorEntity) {
        LoggerUtil.e('❌ 인증 오류: ${result.message} (코드: ${result.statusCode})');
        _appStateViewModel.setError(result.message);
        state = false;
      } else if (result is AuthCancelledEntity) {
        LoggerUtil.i('⚠️ 로그인 취소됨');
        state = false;
      }

      return result;
    } catch (e) {
      LoggerUtil.e('❌ 로그인 중 오류 발생', e);
      _appStateViewModel.setError('로그인 중 오류가 발생했습니다.');
      return AuthResultEntity.error(e.toString());
    } finally {
      _appStateViewModel.setLoading(false);
    }
  }

  /// 로그인 성공 처리
  Future<void> handleSuccessfulLogin(AuthSuccessEntity authResult) async {
    final user = authResult.user;
    await _updateUserSessionData(
        user.userId.toString(), user.email, user.nickname);

    state = true;

    await StorageService.saveToken(authResult.accessToken);
    await StorageService.saveRefreshToken(authResult.refreshToken);

    LoggerUtil.i('✅ 로그인 성공: ${user.nickname}님 환영합니다.');
  }

  /// 로그아웃
  Future<bool> signOut({bool keepUserPreferences = false}) async {
    try {
      _appStateViewModel.setLoading(true);
      await StorageService.secureLogout(
          keepUserPreferences: keepUserPreferences);

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

  /// 로그인 상태 업데이트
  void updateLoginState(bool isLoggedIn) {
    state = isLoggedIn;
    LoggerUtil.d('로그인 상태 업데이트: $isLoggedIn');
  }

  /// 회원가입 진행을 위해 필요한 구글 로그인 정보를 획득합니다.
  Future<Map<String, dynamic>?> getGoogleLoginInfoForSignUp() async {
    try {
      // 메서드 호출 당시 이미 로그인 정보가 있으면 반환
      if (_lastUserInfo != null) {
        return _lastUserInfo;
      }

      _appStateViewModel.setLoading(true);

      // 직접 로그인 시도 (이전 정보 없는 경우)
      LoggerUtil.i('🔍 회원가입을 위한 Google 로그인 정보 획득 시도');
      final result = await signInWithGoogle();

      if (result is AuthNewUserEntity) {
        // 신규 사용자는 이미 _lastUserInfo에 저장되어 있음
        return _lastUserInfo;
      } else {
        LoggerUtil.w('Google 로그인 결과가 신규 사용자가 아님: $result');
        return null;
      }
    } catch (e) {
      LoggerUtil.e('회원가입용 Google 정보 획득 실패', e);
      return null;
    } finally {
      _appStateViewModel.setLoading(false);
    }
  }

  /// 회원가입 데이터 준비
  Future<Map<String, dynamic>> prepareSignUpData({
    required String nickname,
    required String gender,
    required int age,
  }) async {
    final userData = <String, dynamic>{
      'nickname': nickname,
      'gender': gender,
      'age': age,
    };

    // 회원가입용 로그인 정보 획득
    final googleInfo = await getGoogleLoginInfoForSignUp();
    if (googleInfo != null && googleInfo.containsKey('email')) {
      userData['email'] = googleInfo['email'];
    }

    return userData;
  }
}
