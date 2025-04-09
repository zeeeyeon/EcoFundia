import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/exceptions/auth_exception.dart' as core_auth;
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/features/auth/domain/entities/auth_result_entity.dart';
import 'package:front/features/auth/domain/entities/auth_state.dart';
import 'package:front/features/auth/domain/repositories/auth_repository.dart';
import 'package:front/features/auth/domain/use_cases/check_login_status_use_case.dart';
import 'package:front/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:front/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:front/utils/error_handling_mixin.dart';
import 'package:front/utils/logger_util.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart'; // WidgetsBinding 사용 위해 추가
import 'package:jwt_decoder/jwt_decoder.dart';

// Import provider definitions from their actual locations
import 'package:front/features/wishlist/ui/view_model/wishlist_provider.dart';
import 'package:front/features/mypage/ui/view_model/my_funding_view_model.dart';
import 'package:front/features/mypage/ui/view_model/my_review_view_model.dart';
import 'package:front/features/mypage/ui/view_model/profile_view_model.dart';
import 'package:front/features/mypage/ui/view_model/total_funding_provider.dart';
import 'package:front/features/mypage/ui/view_model/coupon_view_model.dart'; // couponViewModelProvider 추가

/// 인증 ViewModel
///
/// 인증 상태를 관리하고 UseCase들을 실행합니다.
class AuthViewModel extends StateNotifier<AuthState>
    with StateNotifierErrorHandlingMixin<AuthState> {
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

  /// JWT 토큰에서 만료 시간을 파싱합니다.
  DateTime _parseTokenExpiry(String token) {
    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      if (!decodedToken.containsKey('exp') || decodedToken['exp'] is! int) {
        throw Exception('Invalid or missing expiration time in token');
      }
      // 만료 시간(epoch seconds)을 DateTime 객체로 변환
      return DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);
    } catch (e) {
      LoggerUtil.e('토큰 만료 시간 파싱 실패', e);
      // 파싱 실패 시 즉시 만료된 것으로 간주하여 안전하게 처리
      return DateTime.now().subtract(const Duration(seconds: 1));
    }
  }

  /// 앱 시작 시 인증 상태를 초기화합니다.
  Future<void> _initializeAuthState() async {
    try {
      if (mounted) _appStateViewModel.setLoading(true);

      final isLoggedIn = await _checkLoginStatusUseCase.execute();
      LoggerUtil.d('🔑 초기 인증 상태 확인: $isLoggedIn');

      if (!mounted) return;

      if (!isLoggedIn) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        _appStateViewModel.setLoggedIn(false);
      } else {
        await _validateAndSetTokens();
        if (!mounted) return;

        if (state.isAuthenticated) {
          LoggerUtil.i('🚀 초기화 시 인증됨, 로그인 후 데이터 로드 시작');
          await _loadPostLoginData();
        } else {
          LoggerUtil.w('⚠️ 초기화 중 토큰 문제 발생, 로그아웃 처리됨');
          if (mounted) _appStateViewModel.setLoggedIn(false);
        }
      }
    } catch (e) {
      LoggerUtil.e('❌ 인증 상태 초기화 실패', e);
      if (mounted) {
        _appStateViewModel.setLoggedIn(false);
        setErrorState(e);
        state = state.copyWith(status: AuthStatus.error, error: errorMessage);
      }
    } finally {
      if (mounted) {
        _appStateViewModel.setInitialized(true);
        _appStateViewModel.setLoading(false);
      }
      LoggerUtil.i('✅ 인증 상태 초기화 절차 완료');
    }
  }

  /// 저장된 토큰을 검증하고 상태를 설정합니다. 만료 시 갱신을 시도합니다.
  Future<void> _validateAndSetTokens() async {
    final token = await StorageService.getToken();
    final refreshToken = await StorageService.getRefreshToken();

    if (!mounted) return;

    if (token != null && refreshToken != null) {
      final tokenExpiry = _parseTokenExpiry(token);
      if (tokenExpiry.isAfter(DateTime.now())) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          accessToken: token,
          refreshToken: refreshToken,
          tokenExpiry: tokenExpiry,
        );
        _appStateViewModel.setLoggedIn(true);
        LoggerUtil.i('✅ 유효한 토큰으로 인증 상태 설정 완료');
      } else {
        LoggerUtil.w('⚠️ 토큰 만료, 갱신 시도');
        await _refreshToken();
      }
    } else {
      LoggerUtil.w('⚠️ 토큰 없음, 인증되지 않은 상태로 설정');
      if (mounted) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        _appStateViewModel.setLoggedIn(false);
      }
    }
  }

  /// 리프레시 토큰을 사용하여 새로운 액세스 토큰과 리프레시 토큰을 발급받습니다.
  Future<void> _refreshToken() async {
    if (_isRefreshing) {
      LoggerUtil.d('🔄 토큰 갱신 중... 중복 요청 무시');
      return _refreshCompleter?.future ?? Future.value();
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<void>();
    LoggerUtil.i('🔄 토큰 갱신 시작');

    try {
      final currentRefreshToken = await StorageService.getRefreshToken();
      if (!mounted) return;

      if (currentRefreshToken == null) {
        throw core_auth.AuthException('리프레시 토큰이 없습니다.');
      }

      final response = await _authRepository.refreshToken(currentRefreshToken);
      if (!mounted) return;

      if (response.accessToken == null || response.refreshToken == null) {
        throw core_auth.AuthException('토큰 갱신 응답 데이터가 올바르지 않습니다.');
      }

      await _saveTokens(response.accessToken!, response.refreshToken!);
      if (!mounted) return;

      state = state.copyWith(
        status: AuthStatus.authenticated,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        tokenExpiry: _parseTokenExpiry(response.accessToken!),
        error: null,
      );
      _appStateViewModel.setLoggedIn(true);

      LoggerUtil.i('✅ 토큰 갱신 성공');
      _refreshCompleter?.complete();
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.response?.statusCode == 401) {
        LoggerUtil.w('❌ 토큰 갱신 실패 (401): 리프레시 토큰 만료 또는 무효. 강제 로그아웃 실행');
        await signOut();
      } else {
        LoggerUtil.e('❌ 토큰 갱신 중 Dio 오류 발생', e);
        setErrorState(e);
        if (mounted)
          state = state.copyWith(status: AuthStatus.error, error: errorMessage);
      }
      if (mounted) _refreshCompleter?.completeError(e);
    } catch (e) {
      if (!mounted) return;
      LoggerUtil.e('❌ 토큰 갱신 중 알 수 없는 오류 발생', e);
      setErrorState(e);
      if (mounted)
        state = state.copyWith(status: AuthStatus.error, error: errorMessage);
      LoggerUtil.w('🔄 알 수 없는 오류로 인한 강제 로그아웃 실행');
      await signOut();
      if (mounted) _refreshCompleter?.completeError(e);
    } finally {
      if (mounted) _isRefreshing = false;
      LoggerUtil.i('🔄 토큰 갱신 절차 종료');
    }
    return _refreshCompleter?.future;
  }

  /// 액세스 토큰과 리프레시 토큰을 안전하게 저장합니다.
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    try {
      await StorageService.saveToken(accessToken);
      await StorageService.saveRefreshToken(refreshToken);
      LoggerUtil.i('💾 토큰 저장 완료');
    } catch (e) {
      LoggerUtil.e('❌ 토큰 저장 실패', e);
      await StorageService.clearAll();
      rethrow;
    }
  }

  /// 인증 성공 후처리 로직 (로그인, 회원가입 완료 시 호출)
  Future<void> _handleAuthSuccess(AuthSuccessEntity result) async {
    LoggerUtil.i('🎯 인증 성공 처리 시작: ${result.user.email}');
    try {
      // 1. 토큰 저장 및 인증 상태 업데이트
      await _saveTokens(result.accessToken, result.refreshToken);
      if (!mounted) return;

      state = state.copyWith(
        status: AuthStatus.authenticated,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        tokenExpiry: _parseTokenExpiry(result.accessToken),
      );
      _appStateViewModel.setLoggedIn(true);
      LoggerUtil.i('✅ 인증 및 AppState 업데이트 완료');

      // 2. 임시 플래그 설정 (데이터 로딩 및 화면 전환 동안 리디렉션 방지)
      _appStateViewModel.setLoggingOut(true);
      LoggerUtil.d('🔄 리디렉션 방지 플래그 설정 (isLoggingOut=true)');

      // 3. 로그인 후 필요한 데이터 로드 (완료될 때까지 기다림)
      LoggerUtil.i('⏳ 로그인 후 데이터 로딩 시작...');
      await _loadPostLoginData();
      if (!mounted) {
        // 데이터 로딩 중 dispose 된 경우 플래그 해제 필요
        _appStateViewModel.setLoggingOut(false);
        LoggerUtil.w('⚠️ 데이터 로딩 중 ViewModel dispose됨, 플래그 해제');
        return;
      }
      LoggerUtil.i('✅ 로그인 후 데이터 로딩 완료');

      // 4. 데이터 로딩 완료 후, 다음 프레임에서 홈으로 이동 및 플래그 해제
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 콜백 실행 시점에는 dispose될 수 있으므로 mounted 체크
        if (mounted) {
          LoggerUtil.d('🔄 Post Frame Callback 시작 (홈 이동 및 플래그 해제)');
          try {
            _router.go('/');
            LoggerUtil.i('🚀 홈 화면으로 이동 시도 (Post Frame)');
          } catch (e) {
            LoggerUtil.e('❌ 홈 이동 중 오류 발생 (Post Frame)', e);
            // 홈 이동 실패 시에도 플래그는 해제해야 함
          } finally {
            // Future.delayed 없이 즉시 플래그 해제
            _appStateViewModel.setLoggingOut(false);
            LoggerUtil.d('🔄 리디렉션 방지 플래그 해제 (isLoggingOut=false) (Post Frame)');
          }
        } else {
          LoggerUtil.w(
              "⚠️ Post Frame Callback 실행 시점에 ViewModel이 이미 dispose됨 (로그인)");
          // dispose 되었어도, AppState의 플래그는 해제 시도 (다른 곳에서 문제 방지)
          _appStateViewModel.setLoggingOut(false);
        }
      });

      LoggerUtil.i('🎉 인증 성공 처리 및 홈 이동 예약 완료');
    } catch (e) {
      LoggerUtil.e('❌ 인증 성공 처리 중 오류 발생', e);
      // 오류 발생 시에도 플래그 해제 및 에러 상태 설정
      if (mounted) {
        _appStateViewModel.setLoggingOut(false);
        setErrorState(e);
        // 필요하다면 로그인 페이지로 리디렉션 또는 다른 에러 처리
      }
    }
    // finally 블록 불필요 (각 분기에서 플래그 해제 처리)
  }

  /// Google 로그인을 시작하고 결과를 처리합니다.
  Future<void> googleSignIn() async {
    if (mounted) {
      _appStateViewModel.setLoading(true);
      state = state.copyWith(status: AuthStatus.initial, error: null);
    }

    try {
      final result = await _googleSignInUseCase.execute();
      // await 이후의 mounted 체크 제거: 후속 핸들러와 finally에서 처리하도록 위임
      // if (!mounted) return;

      if (result is AuthSuccessEntity) {
        await _handleAuthSuccess(result);
      } else if (result is AuthNewUserEntity) {
        _handleNewUserFromEntity(result);
      } else {
        LoggerUtil.w('⚠️ 알 수 없는 인증 결과 타입: ${result.runtimeType}');
        if (mounted) setErrorState(Exception('지원되지 않는 인증 결과 타입입니다.'));
      }
    } catch (e) {
      if (mounted) _handleAuthError(e);
    } finally {
      // mounted 확인 후 상태 변경
      if (mounted) _appStateViewModel.setLoading(false);
    }
  }

  /// 신규 사용자(회원가입 필요) 정보를 처리하고 회원가입 화면으로 이동합니다.
  void _handleNewUserFromEntity(AuthNewUserEntity result) {
    if (!mounted) return;

    LoggerUtil.i('✨ 신규 사용자 감지 (회원가입 필요): ${result.message}');
    _lastUserInfo = {'token': result.token};
    state = state.copyWith(status: AuthStatus.unauthenticated);
    _appStateViewModel.setLoggedIn(false);
    _router.pushNamed('signup', extra: {'token': result.token});
  }

  /// 인증 관련 오류를 처리하고 상태를 업데이트합니다.
  void _handleAuthError(dynamic error) {
    if (!mounted) return;

    LoggerUtil.e('❌ 인증 오류 발생', error);
    setErrorState(error);
    state = state.copyWith(status: AuthStatus.error, error: errorMessage);
    _appStateViewModel.setLoggedIn(false);
  }

  /// 로그아웃을 수행하고 관련 상태 및 데이터를 초기화합니다.
  Future<bool> signOut() async {
    LoggerUtil.i('🚪 로그아웃 시작');
    if (mounted) {
      _appStateViewModel.setLoading(true);
      _appStateViewModel.setLoggingOut(true);
    }

    final completer = Completer<bool>();
    try {
      await _signOutUseCase.execute();
      await _clearLocalData();
      LoggerUtil.i('✅ 로그아웃 작업 완료 (서버/로컬)');

      if (!mounted) {
        completer.complete(false);
        return completer.future;
      }

      try {
        _router.go('/');
        LoggerUtil.i('🚀 홈 화면으로 즉시 이동 시도');
      } catch (e, stackTrace) {
        LoggerUtil.e('❌ 홈 이동 시도 중 즉시 오류 발생', e, stackTrace);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        LoggerUtil.d('🔄 Post Frame Callback 시작 (로그아웃 상태 업데이트)');
        if (mounted) {
          try {
            _appStateViewModel.setLoggedIn(false);
            state = const AuthState(status: AuthStatus.unauthenticated);
            LoggerUtil.i('✅ AuthViewModel 상태 초기화 완료 (Post Frame)');
            _invalidateUserDataProviders();
          } catch (e, stackTrace) {
            LoggerUtil.e('❌ Post Frame Callback 내 상태 업데이트 중 오류', e, stackTrace);
          } finally {
            if (mounted) {
              _appStateViewModel.setLoading(false);
              _appStateViewModel.setLoggingOut(false);
              LoggerUtil.d('🏁 Post Frame Callback 종료 및 플래그/로딩 해제');
            }
          }
        } else {
          LoggerUtil.w("⚠️ Post Frame Callback 실행 시점에 ViewModel이 이미 dispose됨");
        }
      });

      LoggerUtil.i('✅ 로그아웃 절차 완료 (상태 업데이트는 다음 프레임)');
      completer.complete(true);
    } catch (e, stackTrace) {
      LoggerUtil.e('❌ 로그아웃 처리 중 오류 발생 (상태 변경 전)', e, stackTrace);
      if (mounted) {
        try {
          _router.go('/');
          LoggerUtil.w('⚠️ 로그아웃 오류 발생, 홈 화면으로 안전 이동 시도');
        } catch (routeError, routeStackTrace) {
          LoggerUtil.e('❌ 로그아웃 오류 후 홈 화면 이동 실패', routeError, routeStackTrace);
        }
        _appStateViewModel.setLoading(false);
        _appStateViewModel.setLoggingOut(false);
      }
      completer.complete(false);
    }

    return completer.future;
  }

  /// 로컬 저장소의 모든 인증 관련 데이터를 삭제합니다.
  Future<void> _clearLocalData() async {
    try {
      await StorageService.clearAll();
      LoggerUtil.i('🧹 로컬 인증 데이터 삭제 완료');
    } catch (e, stackTrace) {
      LoggerUtil.e('❌ 로컬 데이터 삭제 중 오류', e, stackTrace);
    }
  }

  /// 로그인 후 또는 앱 초기화 시 필요한 사용자 데이터를 로드합니다.
  Future<void> _loadPostLoginData() async {
    await Future.microtask(() async {
      if (!mounted) return;
      LoggerUtil.i('🚀 로그인/초기화 후 데이터 로딩 시작...');
      try {
        await Future.wait([
          _loadWishlistIds(),
          _loadMyPageData(),
        ]);
        if (mounted) LoggerUtil.i('✅ 로그인/초기화 후 데이터 로딩 완료');
      } catch (e) {
        LoggerUtil.e('❌ 로그인/초기화 후 데이터 로딩 중 오류 발생', e);
      }
    });
  }

  /// 위시리스트 ID 목록을 로드합니다.
  Future<void> _loadWishlistIds() async {
    LoggerUtil.d('💖 위시리스트 ID 로딩 시작');
    try {
      final loadFunction = _ref.read(loadWishlistIdsProvider);
      await loadFunction();
      if (mounted) LoggerUtil.d('💖 위시리스트 ID 로딩 완료');
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 ID 로딩 실패', e);
    }
  }

  /// 마이페이지 관련 데이터를 로드합니다.
  Future<void> _loadMyPageData() async {
    LoggerUtil.d('👤 마이페이지 데이터 로딩 시작');
    try {
      final _ = _ref.refresh(totalFundingAmountProvider);
      await Future.wait([
        _ref.read(myFundingViewModelProvider.notifier).fetchMyFundings(),
        _ref.read(myReviewProvider.notifier).fetchReviews(),
        _ref.read(profileProvider.notifier).fetchProfile(),
      ]);
      if (mounted) LoggerUtil.d('👤 마이페이지 데이터 로딩 완료');
    } catch (e) {
      LoggerUtil.e('❌ 마이페이지 데이터 로딩 실패', e);
    }
  }

  /// 로그아웃 시 사용자 관련 데이터 Provider들을 초기화합니다.
  void _invalidateUserDataProviders() {
    LoggerUtil.i('🧹 사용자 관련 데이터 Provider 초기화 중...');
    try {
      final List<ProviderOrFamily> providersToInvalidate = [
        wishlistIdsProvider,
        myFundingViewModelProvider,
        myReviewProvider,
        profileProvider,
        totalFundingAmountProvider,
        couponViewModelProvider,
      ];
      for (var provider in providersToInvalidate) {
        _ref.invalidate(provider);
      }
      LoggerUtil.i('✅ 사용자 관련 데이터 Provider 초기화 완료');
    } catch (e, stackTrace) {
      LoggerUtil.e('❌ 사용자 데이터 Provider 초기화 중 오류', e, stackTrace);
    }
  }

  /// ViewModel의 상태를 초기 상태로 리셋합니다.
  void resetState() {
    if (mounted) {
      state = const AuthState();
      _lastUserInfo = null;
      LoggerUtil.d('🔄 AuthViewModel 상태 리셋 완료');
    }
  }

  Map<String, dynamic>? get lastUserInfo => _lastUserInfo;
}
