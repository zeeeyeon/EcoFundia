import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketManager {
  StompClient? stompClient;
  bool _isConnected = false;
  // 연결 상태 변경 콜백
  Function(bool isConnected)? onConnectionStatusChanged;

  // 연결 상태 접근자
  bool get isConnected => _isConnected;

  // 연결 상태 설정 (내부용)
  set _connected(bool value) {
    if (_isConnected != value) {
      _isConnected = value;
      if (onConnectionStatusChanged != null) {
        onConnectionStatusChanged!(_isConnected);
      }
    }
  }

  void connect({
    String? userToken,
    required void Function(StompFrame frame) onConnectCallback,
    void Function(dynamic error)? onError,
  }) {
    // 헤더 설정 (토큰이 있는 경우에만 인증 헤더 추가)
    Map<String, String> connectHeaders = {};
    Map<String, String> stompHeaders = {};

    if (userToken != null && userToken.isNotEmpty) {
      connectHeaders['Authorization'] = 'Bearer $userToken';
      stompHeaders['Authorization'] = 'Bearer $userToken';
    }

    stompClient = StompClient(
        config: StompConfig(
      url: 'wss://j12e206.p.ssafy.io/ws-stomp', // ✅ WebSocket 엔드포인트
      onConnect: (frame) {
        _connected = true;
        onConnectCallback(frame);
      },
      onWebSocketError: (error) {
        _connected = false;
        if (onError != null) {
          onError(error);
        } else {
          print('❌ WebSocket Error: $error');
        }
      },
      onDisconnect: (frame) {
        _connected = false;
        print('🔌 WebSocket Disconnected');
      },
      onStompError: (frame) {
        _connected = false;
        print('⚠️ STOMP Protocol Error: ${frame.body}');
      },
      beforeConnect: () async {
        print('🔌 Connecting to WebSocket...');
        await Future.delayed(const Duration(milliseconds: 200));
      },
      stompConnectHeaders: stompHeaders,
      webSocketConnectHeaders: connectHeaders,
      heartbeatIncoming: const Duration(seconds: 5),
      heartbeatOutgoing: const Duration(seconds: 5),
    ));

    stompClient!.activate();
  }

  void disconnect() {
    if (stompClient != null) {
      stompClient?.deactivate();
      _connected = false;
    }
  }

  void subscribeToRoom({
    required int fundingId,
    required int userId,
    required void Function(StompFrame frame) onMessage,
  }) {
    // 연결 상태 확인
    if (stompClient == null || !_isConnected) {
      print('❌ STOMP 클라이언트가 연결되지 않았습니다. 구독을 건너뜁니다.');
      return;
    }

    final destination = 'wss://j12e206.p.ssafy.io/sub/chat/$fundingId';

    try {
      stompClient!.subscribe(
        destination: destination,
        headers: {
          'userId': userId.toString(),
        },
        callback: onMessage,
      );
      print('✅ 채팅방 구독 성공: $destination, 유저: $userId');
    } catch (e) {
      print('❌ 채팅방 구독 중 오류 발생: $e');
    }
  }

  // 새로운 안전한 구독 메서드 추가
  void safeSubscribe({
    required String destination,
    required void Function(StompFrame frame) callback,
    Map<String, String>? headers,
  }) {
    // 연결 상태 확인
    if (stompClient == null || !_isConnected) {
      print('❌ WebSocket이 연결되지 않았습니다. 구독을 건너뜁니다: $destination');
      return;
    }

    try {
      print('📩 WebSocket 구독 시도: $destination');
      stompClient!.subscribe(
        destination: destination,
        callback: callback,
        headers: headers ?? {},
      );
      print('✅ WebSocket 구독 성공: $destination');
    } catch (e) {
      print('❌ WebSocket 구독 중 오류 발생: $e');
    }
  }
}
