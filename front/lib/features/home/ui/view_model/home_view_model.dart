import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/home/data/repositories/project_repository_impl.dart';
import 'package:front/features/home/domain/repositories/project_repository.dart';
import 'package:logger/logger.dart';

class HomeState {
  final int totalFund;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.totalFund = 0,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    int? totalFund,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      totalFund: totalFund ?? this.totalFund,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final ProjectRepository _projectRepository;
  final Logger _logger;
  Timer? _refreshTimer;
  DateTime? _lastFetchTime;

  HomeViewModel(this._projectRepository)
      : _logger = Logger(),
        super(const HomeState()) {
    // 초기 데이터 로드
    fetchTotalFund();
    // 1분마다 데이터 갱신
    _startPeriodicRefresh();
  }

  // 디바운싱을 위한 함수 (중복 호출 방지)
  bool _shouldFetch() {
    final now = DateTime.now();
    if (_lastFetchTime == null) return true;

    // 마지막 요청 후 3초 이내에는 다시 요청하지 않음
    final timeDiff = now.difference(_lastFetchTime!).inSeconds;
    return timeDiff > 3;
  }

  void _startPeriodicRefresh() {
    // 기존 타이머가 있다면 취소
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_shouldFetch()) {
        fetchTotalFund();
      }
    });
  }

  Future<void> fetchTotalFund() async {
    // 디바운싱 - 짧은 시간 내 중복 호출 방지
    if (!_shouldFetch()) {
      _logger.d('Skipping fetchTotalFund due to debouncing');
      return;
    }

    _lastFetchTime = DateTime.now();

    try {
      state = state.copyWith(isLoading: true);

      final totalFund = await _projectRepository.getTotalFund();
      _logger.d('Total fund fetched successfully: $totalFund');

      // 로딩 경험을 위한 짧은 지연
      await Future.delayed(const Duration(milliseconds: 300));

      // 값이 변경되었을 때만 상태 업데이트
      if (totalFund != state.totalFund) {
        _logger.d('Total fund updated: ${state.totalFund} -> $totalFund');
        state = state.copyWith(
          totalFund: totalFund,
          isLoading: false,
          error: null,
        );
      } else {
        // 값이 동일하면 로딩 상태만 변경
        state = state.copyWith(isLoading: false, error: null);
        _logger.d('Total fund unchanged: $totalFund');
      }
    } catch (e) {
      _logger.e('Error fetching total fund', error: e);

      // 에러 상태 설정 (totalFund 값은 유지)
      state = state.copyWith(
        isLoading: false,
        error: '총 펀딩 금액을 불러오는데 실패했습니다.',
      );
    }
  }

  // 타이머 재시작 메서드 추가
  void restartTimer() {
    _startPeriodicRefresh();
    fetchTotalFund();
  }

  // 데이터 재로드 없이 타이머만 재시작하는 메서드 추가
  void restartTimerOnly() {
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  final projectRepository = ref.watch(projectRepositoryProvider);
  return HomeViewModel(projectRepository);
});
