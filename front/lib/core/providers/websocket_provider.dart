// core/providers/websocket_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/websocket_manager.dart';

final websocketManagerProvider = Provider<WebSocketManager>((ref) {
  return WebSocketManager();
});
