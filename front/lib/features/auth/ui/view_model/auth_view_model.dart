import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/exceptions/auth_exception.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/features/auth/domain/entities/auth_result_entity.dart';
import 'package:front/features/auth/domain/entities/auth_state.dart';
import 'package:front/features/auth/domain/repositories/auth_repository.dart';
import 'package:front/features/auth/domain/use_cases/check_login_status_use_case.dart';
import 'package:front/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:front/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:front/features/mypage/ui/view_model/my_funding_view_model.dart';
import 'package:front/features/mypage/ui/view_model/my_review_view_model.dart';
import 'package:front/features/mypage/ui/view_model/profile_view_model.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_provider.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_view_model.dart';
import 'package:front/utils/logger_util.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/scheduler.dart';
import 'package:front/features/mypage/ui/view_model/total_funding_provider.dart';

/// 인증 ViewModel
///
/// 인증 상태를 관리하고 UseCase들을 실행합니다.
class AuthViewModel extends StateNotifier<AuthState> {
  final Ref _ref;
  final AppStateViewModel _appStateViewModel;
  final AuthRepository _authRepository;
  final CheckLoginStatusUseCase _checkLoginStatusUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final SignOutUseCase _signOutUseCase;
  final GoRouter _router;

  // 토큰 갱신 관련 상태
  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  // 마지막으로 획득한 사용자 정보 (회원가입 시 사용)
  Map<String, dynamic>? _lastUserInfo;

  // 초기화 상태 플래그
  bool _isInitialized = false;

  AuthViewModel({
    required Ref ref,
    required AppStateViewModel appStateViewModel,
    required AuthRepository authRepository,
    required CheckLoginStatusUseCase checkLoginStatusUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
    required SignOutUseCase signOutUseCase,
    required GoRouter router,
  })  : _ref = ref,
        _appStateViewModel = appStateViewModel,
        _authRepository = authRepository,
        _checkLoginStatusUseCase = checkLoginStatusUseCase,
        _googleSignInUseCase = googleSignInUseCase,
        _signOutUseCase = signOutUseCase,
        _router = router,
        super(const AuthState()) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true;
        _initializeAuthState();
      }
    });
  }

  DateTime _parseTokenExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) throw Exception('Invalid JWT token');

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      return DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
    } catch (e) {
      LoggerUtil.e('토큰 만료 시간 파싱 실패', e);
      return DateTime.now();
    }
  }

  Future<void> _initializeAuthState() async {
    try {
      _appStateViewModel.setLoading(true);

      final isLoggedIn = await _checkLoginStatusUseCase.execute();

      // 인증 상태가 확인되면 앱 상태도 즉시 업데이트 (동기적인 isLoggedInProvider 업데이트)
      _appStateViewModel.setLoggedIn(isLoggedIn);
      LoggerUtil.d('🔑 초기 인증 상태: $isLoggedIn (initializeAuthState)');

      if (!isLoggedIn) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      final token = await StorageService.getToken();
      final refreshToken = await StorageService.getRefreshToken();

      if (token != null && refreshToken != null) {
        final tokenExpiry = _parseTokenExpiry(token);

        if (tokenExpiry.isAfter(DateTime.now())) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            accessToken: token,
            refreshToken: refreshToken,
            tokenExpiry: tokenExpiry,
          );
        } else {
          await _refreshToken();
        }
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      LoggerUtil.e('인증 상태 초기화 실패', e);

      // 오류 발생 시 로그아웃 상태로 설정
      _appStateViewModel.setLoggedIn(false);

      state = state.copyWith(
        status: AuthStatus.error,
        error: '인증 상태 확인 중 오류가 발생했습니다.',
      );
    } finally {
      _appStateViewModel.setLoading(false);
    }
  }

  Future<void> _refreshToken() async {
    if (_isRefreshing) {
      return _refreshCompleter?.future ?? Future.value();
    }

    try {
      _isRefreshing = true;
      _refreshCompleter = Completer<void>();

      if (state.refreshToken == null) {
        throw AuthException('리프레시 토큰이 없습니다.');
      }

      final response = await _authRepository.refreshToken(state.refreshToken!);

      if (response.accessToken == null || response.refreshToken == null) {
        throw AuthException('토큰 정보가 올바르지 않습니다.');
      }

      await _saveTokens(response.accessToken!, response.refreshToken!);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        tokenExpiry: _parseTokenExpiry(response.accessToken!),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await signOut();
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: '토큰 갱신 중 오류가 발생했습니다.',
        );
      }
    } catch (e) {
      LoggerUtil.e('토큰 갱신 실패', e);
      state = state.copyWith(
        status: AuthStatus.error,
        error: '네트워크 연결을 확인해주세요.',
      );
    } finally {
      _isRefreshing = false;
      _refreshCompleter?.complete();
      _refreshCompleter = null;
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await StorageService.saveToken(accessToken);
    await StorageService.saveRefreshToken(refreshToken);
  }

  Future<void> _updateUserSessionData(
    String userId,
    String email,
    String nickname,
  ) async {
    await StorageService.saveUserId(userId);
    await StorageService.saveUserEmail(email);
    await StorageService.saveUserNickname(nickname);
  }

  Future<void> _handleAuthSuccess(AuthSuccessEntity result) async {
    await _updateUserSessionData(
      result.user.userId.toString(),
      result.user.email,
      result.user.nickname,
    );

    await _saveTokens(result.accessToken, result.refreshToken);

    state = state.copyWith(
      status: AuthStatus.authenticated,
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      tokenExpiry: _parseTokenExpiry(result.accessToken),
    );

    // 로그인 성공 후 위시리스트 ID 로딩
    try {
      LoggerUtil.i('🔄 로그인 성공 후 위시리스트 ID 목록 로딩 시작');
      await _ref.read(loadWishlistIdsProvider)();
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 ID 목록 로딩 실패', e);
      // 오류가 발생해도 로그인 플로우는 계속 진행
    }

    LoggerUtil.i('로그인 성공: ${result.user.email}');
  }

  Future<AuthResultEntity> signInWithGoogle() async {
    try {
      _appStateViewModel.setLoading(true);
      _appStateViewModel.clearError();

      final authResult = await _googleSignInUseCase.execute();

      if (authResult is AuthSuccessEntity) {
        await _handleAuthSuccess(authResult);
      } else if (authResult is AuthNewUserEntity) {
        _lastUserInfo = await _authRepository.getGoogleUserInfo();
        if (_lastUserInfo != null) {
          _lastUserInfo!['token'] = authResult.token;
          LoggerUtil.i('회원가입용 Google 정보 획득: $_lastUserInfo');
        }
      } else if (authResult is AuthErrorEntity) {
        state = state.copyWith(
          status: AuthStatus.error,
          error: authResult.message,
        );
        _appStateViewModel.setError(authResult.message);
        LoggerUtil.e(
          '인증 오류: ${authResult.message} (코드: ${authResult.statusCode})',
        );
      } else if (authResult is AuthCancelledEntity) {
        LoggerUtil.i('로그인 취소됨');
      }

      return authResult;
    } catch (e) {
      LoggerUtil.e('로그인 중 오류 발생', e);
      state = state.copyWith(
        status: AuthStatus.error,
        error: '로그인 중 오류가 발생했습니다.',
      );
      _appStateViewModel.setError('로그인 중 오류가 발생했습니다.');
      return const AuthResultEntity.error('로그인 중 오류가 발생했습니다.');
    } finally {
      _appStateViewModel.setLoading(false);
    }
  }

  Future<bool> signOut() async {
    // CancelToken 생성
    final cancelToken = CancelToken();

    try {
      _appStateViewModel.setLoading(true);

      // API 요청으로 로그아웃 처리 (CancelToken 전달)
      await _signOutUseCase.execute(cancelToken: cancelToken);

      // 로컬 스토리지 초기화
      await StorageService.clearAll();

      // 로그아웃 상태로 앱 상태 설정
      _appStateViewModel.setLoggedIn(false);

      // 위시리스트 ID 목록 초기화
      _ref.read(wishlistIdsProvider.notifier).state = <int>{};
      LoggerUtil.i('🧹 위시리스트 ID 목록 초기화 완료');

      // 모든 사용자 관련 Provider 초기화 - 이 목록이 완전해야 함
      _ref.invalidate(profileProvider);
      _ref.invalidate(wishlistViewModelProvider);
      _ref.invalidate(totalFundingAmountProvider);
      _ref.invalidate(myFundingViewModelProvider); // 내가 참여한 펀딩
      _ref.invalidate(myReviewProvider); // 내가 작성한 리뷰
      // 여기에 추가적인 사용자 관련 Provider 무효화 로직 추가 가능

      LoggerUtil.i('✅ 로그아웃 완료 및 모든 사용자 데이터 초기화됨');

      // 앱 상태 업데이트
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        accessToken: null,
        refreshToken: null,
        tokenExpiry: null,
      );

      return true;
    } catch (e) {
      LoggerUtil.e('로그아웃 실패', e);

      // 오류 발생해도 앱 상태는 로그아웃으로 설정
      _appStateViewModel.setLoggedIn(false);

      // 에러 발생 시에도 모든 사용자 관련 Provider 초기화 시도
      try {
        _ref.invalidate(profileProvider);
        _ref.invalidate(wishlistViewModelProvider);
        _ref.invalidate(totalFundingAmountProvider);
        _ref.invalidate(myFundingViewModelProvider);
        _ref.invalidate(myReviewProvider);
        LoggerUtil.i('⚠️ 로그아웃 실패했으나 사용자 데이터는 초기화됨');
      } catch (providerError) {
        LoggerUtil.e('Provider 초기화 실패', providerError);
      }

      state = state.copyWith(
        status: AuthStatus.error,
        error: '로그아웃 중 오류가 발생했습니다.',
      );
      return false;
    } finally {
      _appStateViewModel.setLoading(false);

      // 진행 중인 요청 취소
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('로그아웃 처리 완료');
      }
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
    _appStateViewModel.clearError();
  }

  void resetState() {
    state = const AuthState();
    _appStateViewModel.resetState();
  }

  Future<Map<String, dynamic>?> getGoogleLoginInfoForSignUp() async {
    try {
      if (_lastUserInfo != null) {
        return _lastUserInfo;
      }

      _appStateViewModel.setLoading(true);

      LoggerUtil.i('회원가입을 위한 Google 로그인 정보 획득 시도');
      final result = await signInWithGoogle();

      if (result is AuthNewUserEntity) {
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

    final googleInfo = await getGoogleLoginInfoForSignUp();
    if (googleInfo != null && googleInfo.containsKey('token')) {
      userData['token'] = googleInfo['token'];
    }

    LoggerUtil.d('회원가입 데이터 준비 완료: $userData');
    return userData;
  }

  /// Google 로그인 처리
  Future<void> handleGoogleLogin() async {
    try {
      _appStateViewModel.setLoading(true);
      final result = await signInWithGoogle();

      // 결과 처리
      if (result is AuthSuccessEntity) {
        // 로그인 성공 - 먼저 앱 상태를 업데이트
        _appStateViewModel.setLoggedIn(true);
        LoggerUtil.i('✅ 앱 상태 로그인 업데이트 완료 (handleGoogleLogin)');

        // 인증 관련 데이터가 완전히 반영될 때까지 충분한 지연
        // 이 시간동안 로딩 상태를 유지하여 사용자가 다른 액션을 하지 못하게 함
        LoggerUtil.d('⏳ 인증 데이터 동기화를 위해 대기 중...');
        await Future.delayed(const Duration(milliseconds: 500));
        LoggerUtil.d('✅ 인증 데이터 동기화 완료');

        // 홈 화면으로 이동
        _router.go('/');
      } else if (result is AuthNewUserEntity) {
        // 회원가입 필요 - 회원가입 화면으로 이동
        final userInfo = await getGoogleLoginInfoForSignUp();
        if (userInfo != null) {
          await Future.delayed(const Duration(milliseconds: 50));
          _router.pushNamed('signup', extra: {
            'email': userInfo['email'],
            'name': userInfo['name'],
            'token': userInfo['token'],
          });
        }
      } else if (result is AuthErrorEntity) {
        // 에러 발생 - 로그아웃 상태로 설정
        _appStateViewModel.setLoggedIn(false);
        LoggerUtil.e('❌ 로그인 오류: ${result.message} (앱 상태: 로그아웃)');
        _appStateViewModel.setError(result.message);
      } else if (result is AuthCancelledEntity) {
        // 취소된 경우 - 로그아웃 상태 유지
        _appStateViewModel.setLoggedIn(false);
        LoggerUtil.i('ℹ️ 로그인 취소됨 (앱 상태: 로그아웃)');
      }
    } catch (e) {
      // 모든 예외 처리 - 로그아웃 상태로 설정
      _appStateViewModel.setLoggedIn(false);
      LoggerUtil.e('❌ Google 로그인 실패 (앱 상태: 로그아웃)', e);
      _appStateViewModel.setError('로그인 처리 중 오류가 발생했습니다.');
    } finally {
      // 모든 처리가 끝난 후에만 로딩 상태 해제
      if (_appStateViewModel.state.isLoading) {
        _appStateViewModel.setLoading(false);
      }
    }
  }
}
