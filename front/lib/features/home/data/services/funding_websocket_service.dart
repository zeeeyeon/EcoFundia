import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/websocket_provider.dart';
import 'package:front/core/services/websocket_manager.dart';
import 'package:front/utils/logger_util.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// 펀딩 금액 실시간 업데이트를 위한 WebSocket 서비스
class FundingWebSocketService {
  final WebSocketManager _webSocketManager;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  bool _isReconnecting = false;

  // 재연결 시도 간격 (초)
  static const int _reconnectIntervalSeconds = 5;
  // 최대 재연결 시도 횟수
  static const int _maxReconnectAttempts = 5;
  // 현재 재연결 시도 횟수
  int _reconnectAttempts = 0;

  // 펀딩 금액 업데이트 콜백
  Function(int totalFund)? onTotalFundUpdated;

  // 연결 상태 변경 콜백
  Function(bool isConnected)? onConnectionStatusChanged;

  FundingWebSocketService(this._webSocketManager) {
    // WebSocketManager의 연결 상태 변경 이벤트 구독
    _webSocketManager.onConnectionStatusChanged = _handleConnectionStatusChange;
  }

  // 연결 상태 변경 핸들러
  void _handleConnectionStatusChange(bool connected) {
    if (_isConnected != connected) {
      _isConnected = connected;

      // 연결 상태 콜백 호출
      if (onConnectionStatusChanged != null) {
        onConnectionStatusChanged!(_isConnected);
      }

      // 연결이 끊어졌을 때 자동 재연결 시도
      if (!connected && !_isReconnecting) {
        _scheduleReconnect();
      }
    }
  }

  /// WebSocket 연결 초기화 및 구독 처리
  Future<void> connect() async {
    if (_isConnected) {
      LoggerUtil.d('WebSocket 이미 연결되어 있음');
      return;
    }

    if (_isReconnecting) {
      LoggerUtil.d('WebSocket 재연결 중..');
      return;
    }

    LoggerUtil.i('🔸 총액 펀딩 WebSocket 연결 시작');

    try {
      // 토큰 없이 연결 (총액 구독에는 토큰이 필요 없음)
      _webSocketManager.connect(
        onConnectCallback: _handleConnection,
        onError: _handleError,
      );
    } catch (e) {
      LoggerUtil.e('🔺 WebSocket 연결 시도 중 오류: $e');
      _handleError(e);
    }
  }

  /// 연결 성공 시 호출되는 콜백
  void _handleConnection(StompFrame frame) {
    LoggerUtil.i('🔹 총액 펀딩 WebSocket 연결 성공');
    _isConnected = true;
    _reconnectAttempts = 0; // 재연결 시도 횟수 초기화

    // 연결 상태 콜백 호출
    if (onConnectionStatusChanged != null) {
      onConnectionStatusChanged!(_isConnected);
    }

    // 중요: 연결이 완료된 이후에만 구독 시도
    // 이전 구독 시도가 있었다면 정리
    _subscribeToFundingUpdates();
  }

  /// 에러 발생 시 호출되는 콜백
  void _handleError(dynamic error) {
    LoggerUtil.e('❌ 펀딩 WebSocket 연결 오류: $error');
    _isConnected = false;

    if (onConnectionStatusChanged != null) {
      onConnectionStatusChanged!(_isConnected);
    }

    // 에러 발생 시 자동 재연결 시도
    _scheduleReconnect();
  }

  /// 펀딩 업데이트 구독
  void _subscribeToFundingUpdates() {
    // 연결 상태 확인
    if (!_isConnected || _webSocketManager.stompClient == null) {
      LoggerUtil.w('⚠️ WebSocket이 연결되지 않아 구독을 연기합니다');
      return;
    }

    // 서버에서 지정한 토픽 주소를 사용
    const destination = '/topic/totalAmount';

    // 안전한 구독 메서드 사용
    _webSocketManager.safeSubscribe(
      destination: destination,
      callback: _handleFundingUpdate,
    );

    LoggerUtil.d('🔸 펀딩 총액 업데이트 구독 완료: $destination');
  }

  /// 펀딩 업데이트 처리
  void _handleFundingUpdate(StompFrame frame) {
    try {
      if (frame.body == null) {
        LoggerUtil.w('⚠️ 펀딩 업데이트 수신 - 빈 메시지');
        return;
      }

      LoggerUtil.d('📊 펀딩 업데이트 수신: ${frame.body}');

      final totalFund = _extractTotalFundFromMessage(frame.body!);
      if (totalFund != null) {
        LoggerUtil.i('💰 총 펀딩 금액 업데이트: $totalFund');
        if (onTotalFundUpdated != null) {
          onTotalFundUpdated!(totalFund);
        }
      } else {
        LoggerUtil.w('⚠️ 펀딩 업데이트 파싱 실패');
      }
    } catch (e) {
      LoggerUtil.e('❌ 펀딩 업데이트 처리 오류: $e');
    }
  }

  /// 메시지에서 총 펀딩 금액 추출
  int? _extractTotalFundFromMessage(String message) {
    try {
      final dynamic data = jsonDecode(message);

      // data가 직접 int 값인 경우 (서버가 단순 숫자만 보낼 경우)
      if (data is int) {
        return data;
      }

      // data가 Map이고 totalAmount 필드가 있는 경우
      if (data is Map && data.containsKey('totalAmount')) {
        final totalAmount = data['totalAmount'];
        if (totalAmount is int) {
          return totalAmount;
        } else if (totalAmount is String) {
          return int.tryParse(totalAmount);
        }
      }

      LoggerUtil.w('⚠️ 알 수 없는 데이터 형식: $data');
      return null;
    } catch (e) {
      LoggerUtil.e('❌ JSON 파싱 오류: $e');
      return null;
    }
  }

  /// 연결 상태 확인
  bool get isConnected => _isConnected;

  /// 연결 종료
  void disconnect() {
    _reconnectTimer?.cancel();
    _isReconnecting = false;

    if (_isConnected) {
      _webSocketManager.disconnect();
      _isConnected = false;
      LoggerUtil.d('🔌 펀딩 WebSocket 연결 종료');
    }
  }

  /// 수동 재연결
  Future<void> reconnect() async {
    LoggerUtil.d('🔄 WebSocket 수동 재연결 요청');
    disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    _reconnectAttempts = 0;
    await connect();
  }

  /// 자동 재연결 스케줄링
  void _scheduleReconnect() {
    if (_isReconnecting || _reconnectAttempts >= _maxReconnectAttempts) {
      if (_reconnectAttempts >= _maxReconnectAttempts) {
        LoggerUtil.w('⚠️ 최대 재연결 시도 횟수($_maxReconnectAttempts)에 도달했습니다.');
      }
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts++;

    LoggerUtil.d(
        '🔄 WebSocket 재연결 스케줄링... (시도 $_reconnectAttempts/$_maxReconnectAttempts)');

    // 기존 타이머 취소
    _reconnectTimer?.cancel();

    // 새로운 타이머 설정 (지수 백오프 적용)
    final delay = _reconnectIntervalSeconds * _reconnectAttempts;
    _reconnectTimer = Timer(Duration(seconds: delay), () async {
      LoggerUtil.d('🔄 WebSocket 재연결 시도 $_reconnectAttempts...');
      _isReconnecting = false;

      // 재연결 시도 전 기존 연결 정리
      _webSocketManager.disconnect();
      await Future.delayed(const Duration(milliseconds: 500));

      await connect(); // 재연결 시도
    });
  }
}

/// 펀딩 WebSocket 서비스 제공자
final fundingWebSocketServiceProvider =
    Provider<FundingWebSocketService>((ref) {
  final webSocketManager = ref.watch(websocketManagerProvider);
  return FundingWebSocketService(webSocketManager);
});
