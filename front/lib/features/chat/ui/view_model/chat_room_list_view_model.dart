import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/chat/data/models/chat_room_model.dart';
import 'package:front/features/chat/data/repositories/chat_repository.dart';
import 'package:front/features/chat/providers/chat_repository_provider.dart';

final chatRoomListProvider =
    StateNotifierProvider<ChatRoomListViewModel, AsyncValue<List<ChatRoom>>>(
  (ref) {
    final repo = ref.read(chatRepositoryProvider);
    return ChatRoomListViewModel(repo);
  },
);

class ChatRoomListViewModel extends StateNotifier<AsyncValue<List<ChatRoom>>> {
  final ChatRepository repository;

  ChatRoomListViewModel(this.repository) : super(const AsyncLoading()) {
    fetchChatRooms();
  }

  Future<void> fetchChatRooms() async {
    try {
      final rooms = await repository.getChatRooms();
      state = AsyncValue.data(rooms);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void refresh() => fetchChatRooms();
}
