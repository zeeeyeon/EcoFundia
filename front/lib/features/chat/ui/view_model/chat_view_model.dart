import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/chat/data/models/chat_model.dart';
import 'package:front/features/chat/data/repositories/chat_repository.dart';
import 'package:front/features/chat/providers/chat_repository_provider.dart';

/// 채팅방 ViewModel Provider (fundingId 별로 관리)
final chatRoomViewModelProvider =
    StateNotifierProvider.family<ChatRoomViewModel, List<ChatMessage>, int>(
        (ref, fundingId) {
  final repo = ref.read(chatRepositoryProvider);
  return ChatRoomViewModel(repository: repo, fundingId: fundingId);
});

/// 채팅방 메시지 상태 관리 (조회 + 무한 스크롤 + 수신 추가)
class ChatRoomViewModel extends StateNotifier<List<ChatMessage>> {
  final ChatRepository repository;
  final int fundingId;

  bool isFetchingMore = false;
  bool hasMore = true;
  DateTime? lastFetchedTime;

  ChatRoomViewModel({
    required this.repository,
    required this.fundingId,
  }) : super([]);

  Future<void> fetchMessages() async {
    try {
      final newMessages = await repository.getMessages(
        fundingId: fundingId,
        before: DateTime.now(),
      );

      newMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // 기존 메시지와 병합 (중복 제거)
      final allMessages = [...state, ...newMessages];

      // 중복 제거 (id나 createdAt 기준)
      final uniqueMessages = {
        for (var msg in allMessages)
          '${msg.createdAt.millisecondsSinceEpoch}_${msg.senderId}': msg,
      }.values.toList();

      uniqueMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      state = uniqueMessages;

      if (newMessages.isNotEmpty) {
        lastFetchedTime = newMessages.first.createdAt;
      }

      hasMore = newMessages.isNotEmpty;
    } catch (e) {
      print('❌ 채팅 메시지 초기 로딩 실패: $e');
    }
  }

  /// 🔄 위로 스크롤 시 과거 메시지 더 불러오기
  Future<void> fetchMoreMessages() async {
    if (isFetchingMore || !hasMore) return;

    isFetchingMore = true;
    try {
      final messages = await repository.getMessages(
        fundingId: fundingId,
        before: lastFetchedTime ?? DateTime.now(),
      );

      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (messages.isNotEmpty) {
        lastFetchedTime = messages.first.createdAt;
        state = [...messages, ...state];
        print('📥 ${messages.length}개의 이전 메시지 로딩 완료');
      } else {
        hasMore = false;
        print('⛔ 더 이상 불러올 이전 메시지가 없습니다.');
      }
    } catch (e) {
      print('❌ 채팅 메시지 추가 로딩 실패: $e');
    } finally {
      isFetchingMore = false;
    }
  }

  /// 📩 WebSocket 수신 메시지 추가
  void addMessage(ChatMessage newMessage) {
    final isDuplicate = state.any((msg) =>
        msg.senderId == newMessage.senderId &&
        msg.content == newMessage.content &&
        msg.createdAt == newMessage.createdAt);

    if (!isDuplicate) {
      state = [...state, newMessage];
    }
  }

  /// 🔄 상태 초기화
  void clearMessages() {
    state = [];
    hasMore = true;
    lastFetchedTime = null;
  }
}
