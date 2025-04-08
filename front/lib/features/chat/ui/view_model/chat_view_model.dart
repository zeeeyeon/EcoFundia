import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/chat/data/models/chat_model.dart';
import 'package:front/features/chat/data/repositories/chat_repository.dart';
import 'package:front/features/chat/providers/chat_repository_provider.dart';

final chatRoomViewModelProvider =
    StateNotifierProvider.family<ChatRoomViewModel, List<ChatMessage>, int>(
        (ref, fundingId) {
  final repo = ref.read(chatRepositoryProvider);
  return ChatRoomViewModel(repository: repo, fundingId: fundingId);
});

class ChatRoomViewModel extends StateNotifier<List<ChatMessage>> {
  final ChatRepository repository;
  final int fundingId;

  ChatRoomViewModel({required this.repository, required this.fundingId})
      : super([]);

  Future<void> fetchMessages() async {
    try {
      final messages = await repository.getMessages(fundingId);
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      state = messages;
    } catch (e) {
      print('❌ 채팅 메시지 불러오기 실패: $e');
    }
  }

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void clearMessages() {
    state = [];
  }
}
