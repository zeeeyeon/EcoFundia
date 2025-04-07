import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/websocket_manager.dart';

/// 중앙화된 WebSocketManager Provider
/// 앱에서 WebSocket 연결을 관리하는 싱글톤 인스턴스를 제공
final websocketManagerProvider = Provider<WebSocketManager>((ref) {
  return WebSocketManager();
});
