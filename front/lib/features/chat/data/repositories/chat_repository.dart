import 'package:front/core/services/websocket_manager.dart';

import '../services/chat_service.dart';

class ChatRepository {
  final ChatService _chatService;
  final WebSocketManager _wsManager;

  ChatRepository(this._chatService, this._wsManager);

  Future<bool> leaveChat(int fundingId) async {
    final success = await _chatService.leaveChatRoom(fundingId);
    if (success) {
      _wsManager.leaveLocalSubscription(fundingId);
    }
    return success;
  }
}
