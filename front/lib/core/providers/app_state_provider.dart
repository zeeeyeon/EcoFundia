import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/utils/logger_util.dart';
import 'package:equatable/equatable.dart';
import 'package:front/core/constants/loading_state.dart';

/// 인증이 필요한 기능을 나타내는 열거형
enum AuthRequiredFeature {
  purchase, // 구매
  like, // 좋아요
  comment, // 댓글
  funding, // 펀딩
  profile, // 프로필
}

/// 앱의 전역 상태를 관리하는 클래스
class AppState extends Equatable {
  final bool isLoggedIn;
  final bool isInitialized;
  final LoadingState loadingState;
  final String error;
  final bool isLoggingOut;

  const AppState({
    this.isLoggedIn = false,
    this.isInitialized = false,
    this.loadingState = LoadingState.initial,
    this.error = "",
    this.isLoggingOut = false,
  });

  // isLoading getter 추가 - loadingState 기반으로 이전 isLoading 속성과 호환되도록 함
  bool get isLoading => loadingState == LoadingState.loading;

  AppState copyWith({
    bool? isLoggedIn,
    bool? isInitialized,
    LoadingState? loadingState,
    String? error,
    bool? isLoggingOut,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isInitialized: isInitialized ?? this.isInitialized,
      loadingState: loadingState ?? this.loadingState,
      error: error ?? this.error,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }

  @override
  List<Object?> get props =>
      [isLoggedIn, isInitialized, loadingState, error, isLoggingOut];
}

/// 앱의 전역 상태를 관리하는 ViewModel
class AppStateViewModel extends StateNotifier<AppState> {
  final Ref _ref;

  AppStateViewModel(this._ref) : super(const AppState());

  /// 로딩 상태 설정
  void setLoading(bool isLoading) {
    if (mounted && !state.isLoggingOut) {
      state = state.copyWith(
          loadingState: isLoading ? LoadingState.loading : LoadingState.loaded);
      LoggerUtil.d('🔄 AppState 업데이트: loadingState=${state.loadingState}');
    } else if (mounted) {
      LoggerUtil.d('🔄 isLoggingOut 중이므로 loadingState 변경 건너뜀');
    }
  }

  /// 에러 설정
  void setError(String? error) {
    state = state.copyWith(error: error ?? "");
    if (error != null && error.isNotEmpty) {
      LoggerUtil.e('❌ 에러 발생: $error');
    }
  }

  /// 에러 초기화
  void clearError() {
    state = state.copyWith(error: "");
  }

  /// 로그인 상태 설정
  void setLoggedIn(bool isLoggedIn) {
    state = state.copyWith(isLoggedIn: isLoggedIn);
    LoggerUtil.d('👤 로그인 상태 변경: $isLoggedIn');
  }

  /// 초기화 완료 상태 설정 메서드 추가
  void setInitialized(bool initialized) {
    state = state.copyWith(isInitialized: initialized);
    LoggerUtil.d('🚀 앱 초기화 상태 변경: $initialized');
  }

  /// 로그아웃 처리 (토큰 삭제, 상태 변경, 초기화)
  Future<void> logout() async {
    LoggerUtil.i('🚪 로그아웃 처리 시작');
    try {
      await StorageService.clearAll();
      LoggerUtil.d('🔑 저장된 모든 토큰 삭제 완료');

      // 로그인 상태 및 초기화 상태 초기화
      state = state.copyWith(isLoggedIn: false, isInitialized: false);
      LoggerUtil.i('✅ 로그아웃 상태 변경 및 초기화 완료');
    } catch (e) {
      LoggerUtil.e('❌ 로그아웃 처리 중 오류 발생', e);
      // 오류 시에도 상태는 확실히 초기화
      state = state.copyWith(isLoggedIn: false, isInitialized: false);
    }
  }

  /// 상태 초기화
  void resetState() {
    state = const AppState(); // isInitialized도 false로 초기화됨
    LoggerUtil.i('🔄 앱 상태 완전 초기화');
  }

  /// 로그아웃 진행 중 상태 설정
  void setLoggingOut(bool value) {
    if (mounted) {
      // 로그아웃 시작할 때만 디버깅 로그 추가
      if (value) {
        LoggerUtil.i('🚪 로그아웃 플래그 활성화 - 라우팅 리디렉션 방지');
      }

      // 로그아웃 중인 경우 불필요한 상태 업데이트 방지
      state = state.copyWith(
        isLoggingOut: value,
        // 로그아웃 종료 시에는 로딩 상태도 초기화
        loadingState: !value && state.loadingState == LoadingState.loading
            ? LoadingState.loaded
            : state.loadingState,
      );

      // 로그아웃 완료 시 디버깅 로그 추가
      if (!value) {
        LoggerUtil.i('🚪 로그아웃 플래그 비활성화 - 정상 라우팅 재개');
      } else {
        LoggerUtil.d('🔄 AppState 업데이트: isLoggingOut=$value');
      }
    }
  }
}

/// 앱 상태 Provider
final appStateProvider =
    StateNotifierProvider<AppStateViewModel, AppState>((ref) {
  return AppStateViewModel(ref);
});

/// 로딩 상태 Provider
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).loadingState == LoadingState.loading;
});

/// 에러 상태 Provider
final errorProvider = Provider<String?>((ref) {
  return ref.watch(appStateProvider).error;
});

/// 로그인 상태 Provider (앱 상태에서 가져옴)
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isLoggedIn;
});

/// 초기화 완료 상태 Provider 추가
final isInitializedProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isInitialized;
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
