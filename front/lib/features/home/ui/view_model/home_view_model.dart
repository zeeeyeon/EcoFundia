import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/home/data/repositories/project_repository_impl.dart';
import 'package:front/features/home/data/services/funding_websocket_service.dart';
import 'package:front/features/home/domain/repositories/project_repository.dart';
import 'package:front/utils/logger_util.dart';

/// 홈 화면 상태를 관리하는 클래스
class HomeState {
  /// 총 펀딩 금액
  final int totalFund;

  /// 로딩 상태
  final bool isLoading;

  /// 오류 메시지
  final String? error;

  /// WebSocket 연결 상태
  final bool isWebSocketConnected;

  const HomeState({
    this.totalFund = 0,
    this.isLoading = false,
    this.error,
    this.isWebSocketConnected = false,
  });

  /// 불변 객체 패턴을 사용한 상태 복사 메서드
  HomeState copyWith({
    int? totalFund,
    bool? isLoading,
    String? error,
    bool? isWebSocketConnected,
  }) {
    return HomeState(
      totalFund: totalFund ?? this.totalFund,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isWebSocketConnected: isWebSocketConnected ?? this.isWebSocketConnected,
    );
  }
}

/// 홈 화면의 비즈니스 로직과 상태를 관리하는 ViewModel
class HomeViewModel extends StateNotifier<HomeState> {
  final ProjectRepository _projectRepository;
  final FundingWebSocketService _webSocketService;
  Timer? _refreshTimer;
  DateTime? _lastFetchTime;

  // 디바운싱 설정 (초 단위)
  static const int _debounceDurationSeconds = 5;

  // 폴링 간격 (분 단위)
  static const int _pollingIntervalMinutes = 1;

  HomeViewModel(this._projectRepository, this._webSocketService)
      : super(const HomeState()) {
    _initialize();
  }

  /// 홈 데이터 초기화 및 WebSocket 설정
  Future<void> _initialize() async {
    LoggerUtil.i('🏠 HomeViewModel 초기화 시작');
    try {
      // 초기 데이터 로드
      await _initializeHomeData();

      // WebSocket 연결 설정
      await _initWebSocket();

      LoggerUtil.i('🏠 HomeViewModel 초기화 완료');
    } catch (e) {
      LoggerUtil.e('❌ HomeViewModel 초기화 오류: $e');
      state = state.copyWith(
        error: '데이터 로드 중 오류가 발생했습니다.',
        isLoading: false,
      );
    }
  }

  /// 홈 데이터 초기화 및 WebSocket 설정
  Future<void> _initializeHomeData() async {
    LoggerUtil.d('📊 홈 데이터 초기화 시작');
    state = state.copyWith(isLoading: true);

    try {
      // 첫 데이터 로드
      await fetchTotalFund();

      // WebSocket 연결 상태에 따라 타이머 설정 여부 결정
      if (!state.isWebSocketConnected) {
        _startPeriodicRefresh();
      }

      LoggerUtil.d('📊 홈 데이터 초기화 완료');
    } catch (e) {
      LoggerUtil.e('❌ 홈 데이터 초기화 오류: $e');
      state = state.copyWith(
        error: '데이터 로드 중 오류가 발생했습니다.',
        isLoading: false,
      );
    }
  }

  /// WebSocket 연결 초기화
  Future<void> _initWebSocket() async {
    try {
      LoggerUtil.d('🔌 WebSocket 초기화 시작');

      // WebSocket 연결 상태 변경 콜백 설정
      _webSocketService.onConnectionStatusChanged =
          _handleWebSocketConnectionChange;

      // WebSocket 펀딩 금액 업데이트 콜백 설정
      _webSocketService.onTotalFundUpdated = _handleWebSocketUpdate;

      // 연결 상태 정보 갱신
      state =
          state.copyWith(isWebSocketConnected: _webSocketService.isConnected);

      // WebSocket 연결 시작
      // 중요: connect 내부에서 onConnect 이후에 구독이 수행됨
      await _webSocketService.connect();

      LoggerUtil.i('🔌 WebSocket 실시간 업데이트 초기화 완료');
    } catch (e) {
      LoggerUtil.e('❌ WebSocket 초기화 오류: $e');

      // WebSocket 연결 실패 시 폴백으로 HTTP 폴링 유지
      state = state.copyWith(isWebSocketConnected: false);

      // 연결 실패 시 폴링 시작
      _startPeriodicRefresh();
    }
  }

  /// WebSocket 연결 상태 변경 핸들러
  void _handleWebSocketConnectionChange(bool isConnected) {
    LoggerUtil.i('🔌 WebSocket 연결 상태 변경: $isConnected');

    if (isConnected != state.isWebSocketConnected) {
      state = state.copyWith(isWebSocketConnected: isConnected);

      // 연결 상태에 따라 폴링 설정 변경
      if (isConnected) {
        // WebSocket 연결 성공 시 폴링 중지
        LoggerUtil.d('✅ WebSocket 연결됨 - 폴링 중지');
        _refreshTimer?.cancel();
      } else {
        // WebSocket 연결 끊김 시 폴링 시작
        LoggerUtil.d('❌ WebSocket 연결 끊김 - 폴링 시작');
        _startPeriodicRefresh();

        // 일정 시간 후 자동 재연결 시도
        _scheduleWebSocketReconnect();
      }
    }
  }

  // 자동 WebSocket 재연결 시도
  void _scheduleWebSocketReconnect() {
    if (_webSocketService.isConnected) return;

    Future.delayed(const Duration(seconds: 10), () {
      if (!_webSocketService.isConnected && mounted) {
        LoggerUtil.i('🔄 ViewModel에서 WebSocket 재연결 시도');
        _webSocketService.reconnect();
      }
    });
  }

  /// WebSocket 업데이트 핸들러
  void _handleWebSocketUpdate(int newTotalFund) {
    LoggerUtil.i('📡 WebSocket에서 새로운 펀딩 금액 수신: $newTotalFund');

    // 유효한 금액이 아닌 경우 무시 (0 또는 음수)
    if (newTotalFund <= 0) {
      LoggerUtil.w('⚠️ 유효하지 않은 WebSocket 금액: $newTotalFund - 업데이트 무시');
      return;
    }

    _updateTotalFundIfChanged(newTotalFund);
  }

  /// 값이 변경된 경우에만 상태 업데이트하는 공통 메서드
  void _updateTotalFundIfChanged(int newTotalFund) {
    // 유효한 금액으로의 변경인지 확인 (현재 금액이 0이 아니고, 새 금액이 0인 경우 무시)
    if (state.totalFund > 0 && newTotalFund <= 0) {
      LoggerUtil.w(
          '⚠️ 비정상적인 금액 변경 감지: ${state.totalFund} -> $newTotalFund (무시됨)');
      return;
    }

    if (newTotalFund != state.totalFund) {
      LoggerUtil.d('💰 총 펀딩 금액 업데이트: ${state.totalFund} -> $newTotalFund');
      state = state.copyWith(
        totalFund: newTotalFund,
        isLoading: false,
        error: null,
      );
    } else {
      // 값이 동일하면 로딩 상태만 변경
      if (state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
      LoggerUtil.d('📊 총 펀딩 금액 변동 없음: $newTotalFund');
    }
  }

  /// 디바운싱 - API 중복 호출 방지
  bool _shouldFetch() {
    final now = DateTime.now();
    if (_lastFetchTime == null) return true;

    final timeDiff = now.difference(_lastFetchTime!).inSeconds;
    return timeDiff > _debounceDurationSeconds;
  }

  /// 주기적 데이터 갱신 타이머 설정
  void _startPeriodicRefresh() {
    // 기존 타이머가 있다면 취소
    _refreshTimer?.cancel();

    // WebSocket이 연결된 상태에서는 폴링 불필요
    if (state.isWebSocketConnected) {
      LoggerUtil.d('🔌 WebSocket 연결됨 - 폴링 스킵');
      return;
    }

    // 주기적 HTTP 폴링 (WebSocket 백업)
    _refreshTimer = Timer.periodic(
        const Duration(minutes: _pollingIntervalMinutes),
        (_) => fetchTotalFund());

    LoggerUtil.d('⏱️ 주기적 폴링 타이머 시작 ($_pollingIntervalMinutes분 간격)');
  }

  /// 총 펀딩 금액 조회 API 호출
  Future<void> fetchTotalFund() async {
    // 디바운싱 - 짧은 시간 내 중복 호출 방지
    if (!_shouldFetch()) {
      LoggerUtil.d('중복 요청 방지: fetchTotalFund 스킵');
      return;
    }

    _lastFetchTime = DateTime.now();

    // 이미 로딩 중이면 중복 요청 방지
    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true);

      final totalFund = await _projectRepository.getTotalFund();
      LoggerUtil.d('📊 API에서 총 펀딩 금액 수신: $totalFund');

      // 값 업데이트
      _updateTotalFundIfChanged(totalFund);
    } catch (e) {
      LoggerUtil.e('❌ 총 펀딩 금액 로드 실패: $e');

      // 에러 상태 설정 (totalFund 값은 유지)
      state = state.copyWith(
        isLoading: false,
        error: '총 펀딩 금액을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 타이머와 데이터 새로고침
  Future<void> refreshData() async {
    await fetchTotalFund();

    // WebSocket 연결 상태에 따라 폴링 재설정
    if (!state.isWebSocketConnected) {
      _startPeriodicRefresh();
    }
  }

  /// WebSocket 재연결
  Future<void> reconnectWebSocket() async {
    try {
      LoggerUtil.i('🔄 WebSocket 수동 재연결 시도');

      // 기존 연결 정리
      _webSocketService.disconnect();

      // 상태 업데이트
      state = state.copyWith(isWebSocketConnected: false);

      // 잠시 대기 후 재연결
      await Future.delayed(const Duration(milliseconds: 500));

      // 재연결 시작 (내부에서 onConnect 후 구독함)
      await _webSocketService.connect();
    } catch (e) {
      LoggerUtil.e('❌ WebSocket 재연결 실패: $e');
      // 연결 실패 시 폴링 확인
      if (!state.isWebSocketConnected) {
        _startPeriodicRefresh();
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _webSocketService.disconnect();
    super.dispose();
  }
}

/// HomeViewModel Provider
final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  final projectRepository = ref.watch(projectRepositoryProvider);
  final webSocketService = ref.watch(fundingWebSocketServiceProvider);
  return HomeViewModel(projectRepository, webSocketService);
});
