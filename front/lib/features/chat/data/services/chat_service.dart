import 'package:front/core/services/api_service.dart';
import 'package:front/features/chat/data/models/chat_model.dart';
import 'package:front/features/chat/data/models/chat_room_model.dart';

class ChatService {
  final ApiService _apiService;

  ChatService(this._apiService);

  /// 채팅 메시지 조회 (before: 가장 오래된 메시지 이전)
  Future<List<ChatMessage>> fetchMessages({
    required int fundingId,
    required DateTime before,
  }) async {
    try {
      final response = await _apiService.get(
        '/chat/$fundingId/messages',
        queryParameters: {'before': before.toIso8601String()},
      );

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

  Future<List<ChatRoom>> fetchChatRooms() async {
    try {
      final response = await _apiService.get('/notification/chat/user');

      if (response.statusCode == 200) {
        final List<dynamic> content = response.data['content'];
        return content.map((json) => ChatRoom.fromJson(json)).toList();
      } else {
        throw Exception('채팅방 리스트 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [ChatService] 채팅방 리스트 조회 실패: $e');
      rethrow;
    }
  }

  Future<bool> leaveChatRoom(int fundingId) async {
    try {
      final response =
          await _apiService.delete('/user/$fundingId/participants');

      final statusCode = response.data['status']['code'].toString();
      return statusCode == '200';
    } catch (e) {
      print('❌ [ChatService] 채팅방 나가기 실패: $e');
      return false;
    }
  }
}
