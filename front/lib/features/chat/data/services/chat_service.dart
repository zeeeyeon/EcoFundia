import 'package:front/core/services/api_service.dart';

class ChatService {
  final ApiService _apiService;

  ChatService(this._apiService);

  Future<bool> leaveChatRoom(int fundingId) async {
    try {
      final response =
          await _apiService.delete('/api/user/$fundingId/participants');
      final statusCode = response.data['status']['code'];
      return statusCode == 200;
    } catch (e) {
      print('❌ [ChatService] 채팅방 나가기 실패: $e');
      return false;
    }
  }
}
