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

  Future<bool> leaveChatRoom(int fundingId) async {
    try {
      final success = await repository.leaveChatRoom(fundingId);
      if (success) {
        refresh(); // 리스트 다시 불러오기
      }
      return success;
    } catch (e) {
      print('❌ 채팅방 나가기 실패: $e');
      return false;
    }
  }

  void refresh() => fetchChatRooms();

  /// 상태 초기화 (비로그인 시 호출)
  void resetState() {
    state = const AsyncValue.data([]); // 빈 리스트로 데이터 상태 설정
  }
}
