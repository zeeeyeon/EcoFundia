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
import 'package:jwt_decoder/jwt_decoder.dart';

// Import provider definitions from their actual locations
import 'package:front/features/wishlist/ui/view_model/wishlist_provider.dart';
import 'package:front/features/mypage/ui/view_model/my_funding_view_model.dart';
import 'package:front/features/mypage/ui/view_model/my_review_view_model.dart';
import 'package:front/features/mypage/ui/view_model/profile_view_model.dart';
import 'package:front/features/mypage/ui/view_model/total_funding_provider.dart';

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
      _appStateViewModel.setLoading(true);

      // 1. 로컬 저장소 기반 로그인 상태 확인
      final isLoggedIn = await _checkLoginStatusUseCase.execute();
      LoggerUtil.d('🔑 초기 인증 상태 확인: $isLoggedIn');

      if (!isLoggedIn) {
        // 로그아웃 상태면 ViewModel 상태 업데이트 후 종료
        state = state.copyWith(status: AuthStatus.unauthenticated);
        _appStateViewModel.setLoggedIn(false);
      } else {
        // 로그인 상태면 토큰 확인 및 갱신 시도
        await _validateAndSetTokens();

        // 최종적으로 인증 상태가 확인되면 관련 데이터 로드
        if (state.isAuthenticated) {
          LoggerUtil.i('🚀 초기화 시 인증됨, 로그인 후 데이터 로드 시작');
          await _loadPostLoginData();
        } else {
          // 토큰 갱신 실패 등으로 인증되지 않은 상태가 되면 로그아웃 처리
          LoggerUtil.w('⚠️ 초기화 중 토큰 문제 발생, 로그아웃 처리됨');
          _appStateViewModel.setLoggedIn(false);
        }
      }
    } catch (e) {
      // 초기화 과정 중 예외 발생 시 처리
      LoggerUtil.e('❌ 인증 상태 초기화 실패', e);
      _appStateViewModel.setLoggedIn(false);
      setErrorState(e);
      state = state.copyWith(status: AuthStatus.error, error: errorMessage);
    } finally {
      // 초기화 완료 상태 설정 및 로딩 해제
      _appStateViewModel.setInitialized(true);
      _appStateViewModel.setLoading(false);
      LoggerUtil.i('✅ 인증 상태 초기화 절차 완료');
    }
  }

  /// 저장된 토큰을 검증하고 상태를 설정합니다. 만료 시 갱신을 시도합니다.
  Future<void> _validateAndSetTokens() async {
    final token = await StorageService.getToken();
    final refreshToken = await StorageService.getRefreshToken();

    if (token != null && refreshToken != null) {
      final tokenExpiry = _parseTokenExpiry(token);
      if (tokenExpiry.isAfter(DateTime.now())) {
        // 유효한 토큰: 상태 설정
        state = state.copyWith(
          status: AuthStatus.authenticated,
          accessToken: token,
          refreshToken: refreshToken,
          tokenExpiry: tokenExpiry,
        );
        _appStateViewModel.setLoggedIn(true); // AppState도 동기화
        LoggerUtil.i('✅ 유효한 토큰으로 인증 상태 설정 완료');
      } else {
        // 만료된 토큰: 갱신 시도
        LoggerUtil.w('⚠️ 토큰 만료, 갱신 시도');
        await _refreshToken(); // 갱신 성공 시 내부에서 상태 업데이트 및 setLoggedIn(true) 호출됨
      }
    } else {
      // 토큰 없음: 로그아웃 상태로 처리
      LoggerUtil.w('⚠️ 토큰 없음, 인증되지 않은 상태로 설정');
      state = state.copyWith(status: AuthStatus.unauthenticated);
      _appStateViewModel.setLoggedIn(false);
    }
  }

  /// 리프레시 토큰을 사용하여 새로운 액세스 토큰과 리프레시 토큰을 발급받습니다.
  Future<void> _refreshToken() async {
    // 중복 갱신 방지
    if (_isRefreshing) {
      LoggerUtil.d('🔄 토큰 갱신 중... 중복 요청 무시');
      return _refreshCompleter?.future ?? Future.value();
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<void>();
    LoggerUtil.i('🔄 토큰 갱신 시작');

    try {
      final currentRefreshToken = await StorageService.getRefreshToken();
      if (currentRefreshToken == null) {
        throw core_auth.AuthException('리프레시 토큰이 없습니다.');
      }

      // API 호출하여 토큰 갱신
      final response = await _authRepository.refreshToken(currentRefreshToken);

      if (response.accessToken == null || response.refreshToken == null) {
        throw core_auth.AuthException('토큰 갱신 응답 데이터가 올바르지 않습니다.');
      }

      // 새 토큰 저장
      await _saveTokens(response.accessToken!, response.refreshToken!);

      // ViewModel 상태 업데이트
      state = state.copyWith(
        status: AuthStatus.authenticated,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        tokenExpiry: _parseTokenExpiry(response.accessToken!),
        error: null, // 에러 상태 초기화
      );
      // AppState도 업데이트
      _appStateViewModel.setLoggedIn(true);

      LoggerUtil.i('✅ 토큰 갱신 성공');
      _refreshCompleter?.complete();
    } on DioException catch (e) {
      // Dio 예외 처리 (네트워크 오류 등)
      if (e.response?.statusCode == 401) {
        LoggerUtil.w('❌ 토큰 갱신 실패 (401): 리프레시 토큰 만료 또는 무효. 강제 로그아웃 실행');
        await signOut(); // 갱신 실패 시 로그아웃
      } else {
        LoggerUtil.e('❌ 토큰 갱신 중 Dio 오류 발생', e);
        setErrorState(e);
        state = state.copyWith(status: AuthStatus.error, error: errorMessage);
        // 401 외 Dio 오류 발생 시 로그아웃은 선택 사항 (네트워크 문제일 수 있음)
        // 필요하다면 여기서도 signOut() 호출 가능
      }
      _refreshCompleter?.completeError(e);
    } catch (e) {
      // 기타 예외 처리
      LoggerUtil.e('❌ 토큰 갱신 중 알 수 없는 오류 발생', e);
      setErrorState(e);
      state = state.copyWith(status: AuthStatus.error, error: errorMessage);
      LoggerUtil.w('🔄 알 수 없는 오류로 인한 강제 로그아웃 실행');
      await signOut(); // 일반 오류 발생 시에도 로그아웃 처리
      _refreshCompleter?.completeError(e);
    } finally {
      _isRefreshing = false;
      // _refreshCompleter = null; // Completer 재사용 방지를 위해 null 처리 (필요 시)
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
      // 저장 실패 시 보안을 위해 저장된 모든 인증 정보 삭제
      await StorageService.clearAll();
      rethrow; // 에러를 상위 호출자에게 전파
    }
  }

  /// 사용자 관련 세션 정보를 저장합니다. (ID, 이메일, 닉네임 등)
  Future<void> _updateUserSessionData(
    String userId,
    String email,
    String nickname,
  ) async {
    try {
      await StorageService.saveUserId(userId);
      await StorageService.saveUserEmail(email);
      await StorageService.saveUserNickname(nickname);
      LoggerUtil.i('💾 사용자 세션 데이터 업데이트 완료: $email ($nickname)');
    } catch (e) {
      LoggerUtil.e('❌ 사용자 세션 데이터 저장 실패', e);
      // 저장 실패 시 관련 정보만 삭제하거나 전체 삭제 고려
      // await StorageService.clearUserSessionData();
    }
  }

  /// 인증 성공 후처리 로직 (로그인, 회원가입 완료 시 호출)
  Future<void> _handleAuthSuccess(AuthSuccessEntity result) async {
    LoggerUtil.i('🎉 인증 성공 처리 시작: ${result.user.email}');
    _appStateViewModel.setLoading(true);
    try {
      // 1. 토큰 유효성 검사 (null/empty)
      if (!_isValidToken(result.accessToken) ||
          !_isValidToken(result.refreshToken)) {
        throw Exception('수신된 토큰 정보가 유효하지 않습니다.');
      }

      // 2. 토큰 저장
      await _saveTokens(result.accessToken, result.refreshToken);

      // 3. 사용자 세션 데이터 업데이트
      await _updateUserSessionData(
        result.user.userId.toString(),
        result.user.email,
        result.user.nickname,
      );

      // 4. AuthViewModel 상태 업데이트 (인증됨)
      state = state.copyWith(
        status: AuthStatus.authenticated,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        tokenExpiry: _parseTokenExpiry(result.accessToken),
        error: null, // 성공 시 에러 메시지 초기화
      );
      LoggerUtil.i('✅ AuthViewModel 상태 업데이트 완료 (Authenticated)');

      // 5. AppState 업데이트 (로그인 완료)
      _appStateViewModel.setLoggedIn(true);
      LoggerUtil.i('✅ AppState 로그인 상태 업데이트 완료 (true)');

      // 6. 로그인 후 필요한 데이터 로드 (UI 빌드 이후 비동기 실행)
      await _loadPostLoginData();

      // 7. 로그인 성공 후 홈 화면으로 이동 (addPostFrameCallback 사용)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 현재 프레임 렌더링 완료 후 네비게이션 시도
        try {
          _router.go('/'); // go 사용 (스택 초기화 목적)
          LoggerUtil.i('🚀 로그인 성공 -> 홈 화면으로 go 이동 완료 (Post Frame)');
        } catch (e) {
          LoggerUtil.e('❌ Post Frame 홈 이동 중 오류 발생', e);
          // 필요 시 추가 에러 처리
        }
      });

      LoggerUtil.i('🎉 인증 성공 처리 완료 (Post Frame 네비게이션 예약)');
    } catch (e) {
      LoggerUtil.e('❌ 인증 성공 처리 중 오류 발생', e);
      setErrorState(e);
      state = state.copyWith(status: AuthStatus.error, error: errorMessage);
      // 실패 시 로그아웃 처리하여 상태 일관성 유지
      await signOut();
    } finally {
      _appStateViewModel.setLoading(false);
    }
  }

  /// 토큰 문자열이 유효한지 (null 또는 비어있지 않은지) 확인합니다.
  bool _isValidToken(String? token) {
    return token != null && token.isNotEmpty;
  }

  /// Google 로그인을 시작하고 결과를 처리합니다.
  Future<void> googleSignIn() async {
    _appStateViewModel.setLoading(true);
    state =
        state.copyWith(status: AuthStatus.initial, error: null); // 이전 상태 초기화
    try {
      final result = await _googleSignInUseCase.execute();

      // 인증 결과 타입에 따라 분기 처리
      if (result is AuthSuccessEntity) {
        await _handleAuthSuccess(result); // 기존 사용자 로그인 성공
      } else if (result is AuthNewUserEntity) {
        _handleNewUserFromEntity(result); // 신규 사용자 (회원가입 필요)
      } else if (result is AuthErrorEntity) {
        _handleAuthError(result.message); // 인증 오류
      } else if (result is AuthCancelledEntity) {
        LoggerUtil.i('로그인 취소됨');
        _appStateViewModel.setLoggedIn(false); // 명시적으로 로그아웃 상태 설정
        state = state.copyWith(status: AuthStatus.unauthenticated); // 상태도 반영
      } else {
        _handleAuthError('알 수 없는 인증 결과 타입'); // 예외 케이스 처리
      }
    } catch (e) {
      _handleAuthError(e); // UseCase 실행 중 발생한 예외 처리
    } finally {
      _appStateViewModel.setLoading(false);
    }
  }

  /// 신규 사용자(회원가입 필요) 정보를 처리하고 회원가입 화면으로 이동합니다.
  void _handleNewUserFromEntity(AuthNewUserEntity result) {
    LoggerUtil.i('✨ 신규 사용자 감지 (회원가입 필요): ${result.message}');
    // 회원가입 완료에 필요한 임시 토큰 저장
    _lastUserInfo = {'token': result.token};
    state =
        state.copyWith(status: AuthStatus.unauthenticated); // 회원가입 전까지는 미인증 상태
    _appStateViewModel.setLoggedIn(false);
    // 회원가입 페이지로 이동 (토큰 전달)
    _router.pushNamed('signup', extra: {'token': result.token});
  }

  /// 인증 관련 오류를 처리하고 상태를 업데이트합니다.
  void _handleAuthError(dynamic error) {
    LoggerUtil.e('❌ 인증 오류 발생', error);
    setErrorState(error); // Mixin을 사용하여 에러 메시지 설정
    state = state.copyWith(status: AuthStatus.error, error: errorMessage);
    _appStateViewModel.setLoggedIn(false); // 오류 발생 시 로그아웃 상태로 간주
  }

  /// 로그아웃을 수행하고 관련 상태 및 데이터를 초기화합니다.
  Future<bool> signOut() async {
    LoggerUtil.i('🚪 로그아웃 시작');
    _appStateViewModel.setLoading(true);
    final completer = Completer<bool>();
    try {
      // 1. 서버 로그아웃 요청 (필요 시)
      await _signOutUseCase.execute();
      // 2. 로컬 데이터 삭제
      await _clearLocalData();
      // 3. AppState 업데이트 (로그아웃)
      _appStateViewModel.setLoggedIn(false);
      // 4. AuthViewModel 상태 초기화 (미인증)
      state = const AuthState(status: AuthStatus.unauthenticated);
      // 5. 사용자 관련 데이터 Provider 초기화
      _invalidateUserDataProviders();

      LoggerUtil.i('✅ 로그아웃 성공');

      // 로그아웃 성공 시 홈 화면으로 이동 (addPostFrameCallback 사용)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _router.go('/'); // go 사용 (스택 초기화 목적)
          LoggerUtil.i('🚀 로그아웃 성공 -> 홈 화면으로 go 이동 완료 (Post Frame)');
        } catch (e) {
          LoggerUtil.e('❌ Post Frame 홈 이동 중 오류 발생 (로그아웃)', e);
        }
      });

      completer.complete(true);
    } catch (e) {
      LoggerUtil.e('❌ 로그아웃 실패', e);
      setErrorState(e);
      // 실패 시에도 로컬 데이터 정리 및 상태 변경 시도 (UI 일관성 유지)
      await _clearLocalData();
      _appStateViewModel.setLoggedIn(false);
      state = const AuthState(
          status: AuthStatus.unauthenticated, error: '로그아웃 중 오류 발생');
      completer.complete(false); // 실패 플래그 반환
    } finally {
      _appStateViewModel.setLoading(false);
    }
    return completer.future;
  }

  /// 로컬 저장소의 모든 인증 관련 데이터를 삭제합니다.
  Future<void> _clearLocalData() async {
    try {
      await StorageService.clearAll();
      LoggerUtil.i('🧹 로컬 인증 데이터 삭제 완료');
    } catch (e) {
      LoggerUtil.e('❌ 로컬 데이터 삭제 실패', e);
    }
  }

  /// 로그인 후 또는 앱 초기화 시 필요한 사용자 데이터를 로드합니다.
  Future<void> _loadPostLoginData() async {
    // microtask를 사용하여 UI 빌드가 완료된 후 비동기적으로 실행
    await Future.microtask(() async {
      LoggerUtil.i('🚀 로그인/초기화 후 데이터 로딩 시작...');
      try {
        // 여러 데이터 로드를 병렬로 실행하여 시간 단축
        await Future.wait([
          _loadWishlistIds(), // 위시리스트 ID 로드
          _loadMyPageData(), // 마이페이지 관련 데이터 로드
          // 필요시 다른 데이터 로드 Future 추가
        ]);
        LoggerUtil.i('✅ 로그인/초기화 후 데이터 로딩 완료');
      } catch (e) {
        // 개별 데이터 로드 실패는 로그로 남기되, 전체 인증 흐름을 막지 않음
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
      LoggerUtil.d('💖 위시리스트 ID 로딩 완료');
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 ID 로딩 실패', e);
      // 실패해도 계속 진행
    }
  }

  /// 마이페이지 관련 데이터를 로드합니다.
  Future<void> _loadMyPageData() async {
    LoggerUtil.d('👤 마이페이지 데이터 로딩 시작');
    try {
      // FutureProvider는 refresh, StateNotifier는 메서드 호출
      // Assign the result to _ to indicate it's intentionally unused
      final _ = _ref.refresh(totalFundingAmountProvider);
      await Future.wait([
        _ref.read(myFundingViewModelProvider.notifier).fetchMyFundings(),
        _ref.read(myReviewProvider.notifier).fetchReviews(),
        _ref.read(profileProvider.notifier).fetchProfile(),
        // 다른 마이페이지 관련 StateNotifier 로딩 메서드 호출 추가
      ]);
      LoggerUtil.d('👤 마이페이지 데이터 로딩 완료');
    } catch (e) {
      LoggerUtil.e('❌ 마이페이지 데이터 로딩 실패', e);
      // 실패해도 계속 진행
    }
  }

  /// 로그아웃 시 사용자 관련 데이터 Provider들을 초기화합니다.
  void _invalidateUserDataProviders() {
    LoggerUtil.i('🧹 사용자 관련 데이터 Provider 초기화 중...');
    try {
      // 초기화할 Provider 목록 (타입 명시)
      final List<ProviderOrFamily> providersToInvalidate = [
        wishlistIdsProvider,
        myFundingViewModelProvider,
        myReviewProvider,
        profileProvider,
        totalFundingAmountProvider,
        // 다른 사용자 관련 Provider 추가 시 여기에 명시적으로 타입 캐스팅 필요할 수 있음
      ];
      for (var provider in providersToInvalidate) {
        _ref.invalidate(provider);
      }
      LoggerUtil.i('✅ 사용자 관련 데이터 Provider 초기화 완료');
    } catch (e) {
      // Provider 초기화 실패는 로깅만 하고 넘어감
      LoggerUtil.e('❌ Provider 초기화 중 오류 발생', e);
    }
  }

  /// ViewModel의 상태를 초기 상태로 리셋합니다.
  void resetState() {
    state = const AuthState(); // 초기 상태로 되돌림
    _lastUserInfo = null; // 회원가입 관련 정보 초기화
    LoggerUtil.d('🔄 AuthViewModel 상태 리셋 완료');
  }

  // CompleterSignUpUseCase 실행 관련 로직
  // ... (기존 completeSignUp 관련 로직이 있다면 유지)

  /// 회원가입 시 사용된 임시 사용자 정보를 반환합니다.
  Map<String, dynamic>? get lastUserInfo => _lastUserInfo;
}
