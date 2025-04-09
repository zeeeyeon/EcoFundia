import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/utils/logger_util.dart';

/// 인증이 필요한 기능을 나타내는 열거형
enum AuthRequiredFeature {
  purchase, // 구매
  like, // 좋아요
  comment, // 댓글
  funding, // 펀딩
  profile, // 프로필
}

/// 앱의 전역 상태를 관리하는 클래스
class AppState {
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;

  const AppState({
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
  });

  AppState copyWith({
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

/// 앱의 전역 상태를 관리하는 ViewModel
class AppStateViewModel extends StateNotifier<AppState> {
  final Ref _ref;

  AppStateViewModel(this._ref) : super(const AppState());

  /// 로딩 상태 설정
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
    LoggerUtil.d('🔄 로딩 상태 변경: $isLoading');
  }

  /// 에러 설정
  void setError(String? error) {
    state = state.copyWith(error: error);
    if (error != null) {
      LoggerUtil.e('❌ 에러 발생: $error');
    }
  }

  /// 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 로그인 상태 설정
  void setLoggedIn(bool isLoggedIn) {
    state = state.copyWith(isLoggedIn: isLoggedIn);
    LoggerUtil.d('👤 로그인 상태 변경: $isLoggedIn');
  }

  /// 로그아웃 처리 (토큰 삭제, 상태 변경, 로그인 페이지 이동)
  Future<void> logout() async {
    LoggerUtil.i('🚪 로그아웃 처리 시작');
    try {
      // 1. 토큰 삭제
      await StorageService.clearAll();
      LoggerUtil.d('🔑 저장된 모든 토큰 삭제 완료');

      // 2. 로그인 상태 변경
      setLoggedIn(false);

      // 3. 로그인 페이지 리디렉션 -> GoRouter redirect에서 처리하도록 제거
      // _ref.read(routerProvider).go('/login');
      LoggerUtil.i('✅ 로그아웃 상태 변경 완료');
    } catch (e) {
      LoggerUtil.e('❌ 로그아웃 처리 중 오류 발생', e);
      state = state.copyWith(isLoggedIn: false); // 상태는 확실히 false로
      // 오류 시 라우팅 시도 제거
      // try {
      //   _ref.read(routerProvider).go('/login');
      // } catch (routerError) {
      //   LoggerUtil.e('❌ 로그아웃 후 라우팅 오류', routerError);
      // }
    }
  }

  /// 상태 초기화
  void resetState() {
    state = const AppState();
  }
}

/// 앱 상태 Provider
final appStateProvider =
    StateNotifierProvider<AppStateViewModel, AppState>((ref) {
  return AppStateViewModel(ref);
});

/// 로딩 상태 Provider
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isLoading;
});

/// 에러 상태 Provider
final errorProvider = Provider<String?>((ref) {
  return ref.watch(appStateProvider).error;
});

/// 로그인 상태 Provider (앱 상태에서 가져옴)
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isLoggedIn;
});

/// 로그인 상태 체크 Provider (비동기)
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  try {
    // 1. 토큰 존재 여부 확인
    final token = await StorageService.getToken();
    if (token == null) {
      LoggerUtil.d('🔑 인증 상태 체크: 토큰 없음');
      ref.read(appStateProvider.notifier).setLoggedIn(false);
      return false;
    }

    // 2. 토큰 유효성 검사
    final hasValidToken = await StorageService.isAuthenticated();

    // 3. 상태 업데이트 - 앱 전체 상태 동기화
    ref.read(appStateProvider.notifier).setLoggedIn(hasValidToken);

    if (!hasValidToken) {
      LoggerUtil.d('🔑 인증 상태 체크: 유효하지 않은 토큰');
    } else {
      LoggerUtil.d('🔑 인증 상태 체크: 유효한 토큰 확인됨');
    }

    return hasValidToken;
  } catch (e) {
    LoggerUtil.e('인증 상태 체크 중 오류 발생', e);
    // 오류 발생 시 로그아웃 상태로 처리
    ref.read(appStateProvider.notifier).setLoggedIn(false);
    return false;
  }
});

/// 특정 기능에 인증이 필요한지 확인하는 Provider
final requiresAuthProvider =
    Provider.family<bool, AuthRequiredFeature>((ref, feature) {
  // 모든 기능을 엄격하게 인증 필요한 것으로 처리
  switch (feature) {
    case AuthRequiredFeature.purchase:
    case AuthRequiredFeature.like: // 좋아요(하트) 버튼
    case AuthRequiredFeature.comment:
    case AuthRequiredFeature.funding:
    case AuthRequiredFeature.profile:
      return true;
    default:
      return true; // 기본값도 인증 필요로 설정 (안전하게)
  }
});
