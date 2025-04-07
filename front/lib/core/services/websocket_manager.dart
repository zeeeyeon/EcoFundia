import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

/// WebSocket 연결 및 채팅 구독을 담당하는 매니저 클래스
class WebSocketManager {
  StompClient? _client;
  bool _isConnected = false;

  // 구독 상태 관리: fundingId 기준으로 Unsubscribe 함수 저장
  final Map<int, StompUnsubscribe> _unsubscribeMap = {};

  /// 현재 WebSocket 연결 여부
  bool get isConnected => _isConnected;

  /// WebSocket 연결 시작
  void connect({
    required String userToken,
    required void Function(StompFrame frame) onConnectCallback,
    void Function(dynamic error)? onError,
  }) {
    // 이미 연결된 상태면 중복 연결 방지
    if (_client != null && _client!.connected) {
      print('✅ 이미 WebSocket에 연결되어 있습니다.');
      return;
    }

    _client = StompClient(
      config: StompConfig(
        url: 'wss://j12e206.p.ssafy.io/ws-stomp', // 반드시 `/`로 끝나야 함
        onConnect: (frame) {
          print('✅ WebSocket 연결 성공');
          _isConnected = true;
          onConnectCallback(frame);
        },
        beforeConnect: () async {
          print('🔌 WebSocket 연결 시도 중...');
          await Future.delayed(const Duration(milliseconds: 200));
        },
        onWebSocketError: onError ??
            (error) {
              print('❌ WebSocket 연결 오류: $error');
            },
        stompConnectHeaders: {
          'Authorization': 'Bearer $userToken',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $userToken',
        },
        heartbeatIncoming: const Duration(seconds: 0),
        heartbeatOutgoing: const Duration(seconds: 0),
      ),
    );

    _client!.activate();
  }

  /// 채팅방(fundingId) 구독
  void subscribeToRoom({
    required int fundingId,
    required int userId,
    required void Function(StompFrame frame) onMessage,
  }) {
    final destination = '/sub/chat/$fundingId';

    // ✅ 기존 구독이 있다면 해제
    if (_unsubscribeMap.containsKey(fundingId)) {
      print('🔁 기존 구독 해제: $destination');
      _unsubscribeMap[fundingId]?.call();
      _unsubscribeMap.remove(fundingId);
    }

    // 📨 구독 요청
    final unsubscribe = _client?.subscribe(
      destination: destination,
      headers: {
        'userId': userId.toString(),
      },
      callback: onMessage,
    );

    if (unsubscribe != null) {
      _unsubscribeMap[fundingId] = unsubscribe;
    }
  }

  void sendMessageToRoom({
    required int fundingId,
    required int senderId,
    required String nickname,
    required String content,
    DateTime? createdAt, // ✅ 선택적 파라미터로 받기
  }) {
    final destination = '/pub/chat/$fundingId';

    print('📤 채팅 메시지 전송 → $destination');
    _client?.send(
      destination: destination,
      body: jsonEncode({
        'fundingId': fundingId,
        'senderId': senderId,
        'nickname': nickname,
        'content': content,
        if (createdAt != null)
          'createdAt': createdAt.toIso8601String(), // ✅ ISO 포맷으로 전송
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  /// 전체 구독 해제 및 WebSocket 연결 종료
  void disconnect() {
    print('🔌 WebSocket 연결 해제 중...');
    for (final unsub in _unsubscribeMap.values) {
      unsub.call();
    }

    _unsubscribeMap.clear();
    _client?.deactivate();
    _client = null;
    _isConnected = false;
  }
}
