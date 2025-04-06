import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketManager {
  StompClient? stompClient;

  void connect({
    required String userToken,
    required void Function(StompFrame frame) onConnectCallback,
    void Function(dynamic error)? onError,
  }) {
    stompClient = StompClient(
        config: StompConfig(
      url: 'wss://j12e206.p.ssafy.io/ws-stomp', // ✅ 정확한 WebSocket 엔드포인트
      onConnect: onConnectCallback,
      onWebSocketError: onError ??
          (error) {
            print('❌ WebSocket Error: $error');
          },
      beforeConnect: () async {
        print('🔌 Connecting to WebSocket...');
        await Future.delayed(const Duration(milliseconds: 200));
      },
      stompConnectHeaders: {
        'Authorization': 'Bearer $userToken',
      },
      webSocketConnectHeaders: {
        'Authorization': 'Bearer $userToken',
      },
      heartbeatIncoming: const Duration(seconds: 0),
      heartbeatOutgoing: const Duration(seconds: 0),
    ));

    stompClient!.activate();
  }

  void disconnect() {
    stompClient?.deactivate();
  }
}
