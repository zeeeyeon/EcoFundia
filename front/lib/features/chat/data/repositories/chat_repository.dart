import 'package:front/core/services/websocket_manager.dart';
import 'package:front/features/chat/data/models/chat_model.dart';
import 'package:front/features/chat/data/services/chat_service.dart';

class ChatRepository {
  final ChatService _chatService;
  final WebSocketManager _wsManager;

  ChatRepository(this._chatService, this._wsManager);

  /// 채팅 메시지 가져오기 (ViewModel에서 호출)
  Future<List<ChatMessage>> getMessages(int fundingId) {
    return _chatService.fetchMessages(fundingId);
  }
}
