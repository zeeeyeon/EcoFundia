import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/websocket_provider.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/ui/widgets/custom_app_bar.dart';
import 'package:front/features/chat/ui/view_model/chat_room_list_view_model.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus =
        ref.watch(websocketManagerProvider.select((ws) => ws.isConnected))
            ? '✅ WebSocket 연결됨'
            : '⏳ WebSocket 연결 시도 중...';

    final asyncChatRooms = ref.watch(chatRoomListProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: "My Chats"),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: Colors.grey[200],
            child: Text(
              connectionStatus,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: asyncChatRooms.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('오류 발생: $err')),
              data: (rooms) => rooms.isEmpty
                  ? const Center(child: Text('참여 중인 채팅방이 없습니다.'))
                  : ListView.separated(
                      itemCount: rooms.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        return ListTile(
                          leading: const Icon(Icons.forum_outlined,
                              color: AppColors.primary),
                          title: Text(
                            room.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: room.lastMessage != null
                              ? Text(
                                  room.lastMessage!,
                                  style: TextStyle(color: Colors.grey[600]),
                                )
                              : null,
                          trailing: const Icon(Icons.chevron_right,
                              color: AppColors.primary),
                          onTap: () async {
                            final result = await context.push(
                              '/chat/room/${room.fundingId}',
                              extra: {'fundingTitle': room.title},
                            );

                            if (result == 'refresh') {
                              ref.read(chatRoomListProvider.notifier).refresh();
                            }
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
