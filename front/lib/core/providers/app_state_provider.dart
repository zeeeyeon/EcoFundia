import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/utils/logger_util.dart';

/// 앱의 전역 상태를 관리하는 클래스
class AppState {
  final bool isLoading;
  final String? error;

  const AppState({
    this.isLoading = false,
    this.error,
  });

  AppState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 앱의 전역 상태를 관리하는 ViewModel
class AppStateViewModel extends StateNotifier<AppState> {
  AppStateViewModel() : super(const AppState());

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

  /// 상태 초기화
  void resetState() {
    state = const AppState();
  }
}

/// 앱 상태 Provider
final appStateProvider =
    StateNotifierProvider<AppStateViewModel, AppState>((ref) {
  return AppStateViewModel();
});

/// 로딩 상태 Provider
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isLoading;
});

/// 에러 상태 Provider
final errorProvider = Provider<String?>((ref) {
  return ref.watch(appStateProvider).error;
});
