import 'package:front/core/services/api_service.dart';
import 'package:front/features/chat/data/models/chat_model.dart';

class ChatService {
  final ApiService _apiService;

  ChatService(this._apiService);

  /// 채팅 메시지 조회
  Future<List<ChatMessage>> fetchMessages(int fundingId) async {
    try {
      final response =
          await _apiService.get('/api/user/chat/$fundingId/messages');

      if (response.statusCode == 200) {
        final content = response.data['content'] as List<dynamic>;
        return content.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('메시지 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [ChatService] 메시지 조회 실패: $e');
      rethrow;
    }
  }
}
