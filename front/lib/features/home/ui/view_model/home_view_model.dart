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

  HomeViewModel(this._projectRepository)
      : _logger = Logger(),
        super(const HomeState()) {
    // 초기 데이터 로드
    fetchTotalFund();
    // 30초마다 데이터 갱신
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchTotalFund();
    });
  }

  Future<void> fetchTotalFund() async {
    try {
      state = state.copyWith(isLoading: true);
      final totalFund = await _projectRepository.getTotalFund();
      state = state.copyWith(
        totalFund: totalFund,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      _logger.e('Error fetching total fund', error: e);
      state = state.copyWith(
        isLoading: false,
        error: '총 펀딩 금액을 불러오는데 실패했습니다.',
      );
    }
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
