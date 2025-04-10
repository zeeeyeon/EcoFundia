// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:front/core/themes/app_colors.dart';
// import 'package:front/core/ui/widgets/custom_app_bar.dart';
// import 'package:front/features/chat/ui/view_model/chat_room_list_view_model.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';

// class ChatScreen extends ConsumerWidget {
//   const ChatScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final asyncChatRooms = ref.watch(chatRoomListProvider);

//     return Scaffold(
//       appBar: const CustomAppBar(title: "💬 채팅방 목록"),
//       body: Column(
//         children: [
//           Expanded(
//             child: asyncChatRooms.when(
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (err, _) => Center(child: Text('오류 발생: $err')),
//               data: (rooms) => rooms.isEmpty
//                   ? const Center(
//                       child: Text(
//                         '참여 중인 채팅방이 없습니다.',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     )
//                   : ListView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       itemCount: rooms.length,
//                       itemBuilder: (context, index) {
//                         final room = rooms[index];
//                         final lastMessageTime = room.lastMessageAt != null
//                             ? DateFormat('MM/dd HH:mm')
//                                 .format(room.lastMessageAt!)
//                             : '메시지 없음';

//                         return Dismissible(
//                           key: ValueKey(room.fundingId),
//                           direction: DismissDirection.endToStart,
//                           background: Container(
//                             alignment: Alignment.centerRight,
//                             padding: const EdgeInsets.symmetric(horizontal: 20),
//                             margin: const EdgeInsets.only(bottom: 12),
//                             decoration: BoxDecoration(
//                               color: Colors.redAccent,
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: const Icon(Icons.delete_outline,
//                                 color: Colors.white),
//                           ),
//                           confirmDismiss: (_) async {
//                             final confirm = await showDialog<bool>(
//                               context: context,
//                               builder: (context) => AlertDialog(
//                                 title: const Text("채팅방 나가기"),
//                                 content: const Text("정말로 나가시겠습니까?"),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () =>
//                                         Navigator.pop(context, false),
//                                     child: const Text("취소"),
//                                   ),
//                                   TextButton(
//                                     onPressed: () =>
//                                         Navigator.pop(context, true),
//                                     child: const Text("나가기"),
//                                   ),
//                                 ],
//                               ),
//                             );
//                             return confirm ?? false;
//                           },
//                           onDismissed: (_) async {
//                             final success = await ref
//                                 .read(chatRoomListProvider.notifier)
//                                 .leaveChatRoom(room.fundingId);

//                             if (success) {
//                               ref.read(chatRoomListProvider.notifier).refresh();
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                     content: Text('채팅방 나가기에 실패했습니다.')),
//                               );
//                             }
//                           },
//                           child: Card(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16)),
//                             elevation: 4,
//                             margin: const EdgeInsets.only(bottom: 12),
//                             child: ListTile(
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 12),
//                               leading: const CircleAvatar(
//                                 backgroundColor: AppColors.primary,
//                                 child: Icon(Icons.forum, color: Colors.white),
//                               ),
//                               title: Text(
//                                 room.title,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               subtitle: Text(
//                                 room.lastMessage ?? '마지막 메시지가 없습니다',
//                                 style: TextStyle(
//                                   color: Colors.grey[700],
//                                   fontSize: 13,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               trailing: Text(
//                                 lastMessageTime,
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey[500],
//                                 ),
//                               ),
//                               onTap: () async {
//                                 final result = await context.push(
//                                   '/chat/room/${room.fundingId}',
//                                   extra: {'fundingTitle': room.title},
//                                 );
//                                 if (result == 'refresh') {
//                                   ref
//                                       .read(chatRoomListProvider.notifier)
//                                       .refresh();
//                                 }
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/ui/widgets/custom_app_bar.dart';
import 'package:front/features/chat/ui/view_model/chat_room_list_view_model.dart';
import 'package:front/utils/logger_util.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    if (!isLoggedIn && context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.pushReplacement('/login');
          LoggerUtil.d('🔒 채팅 탭 접근 시 로그인 상태 아님 확인 -> 로그인 페이지로 리디렉션');
        }
      });
      return const Scaffold(body: Center(child: SizedBox.shrink()));
    }

    final asyncChatRooms = ref.watch(chatRoomListProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: "💬 My Chats"),
      body: Column(
        children: [
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
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SizedBox(
                            height: 80, // ✅ 고정 높이 설정
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.1),
                                radius: 24,
                                child: const Icon(Icons.forum_outlined,
                                    color: AppColors.primary),
                              ),
                              title: Text(
                                room.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis, // ✅ 제목도 말줄임
                              ),
                              subtitle: room.lastMessage != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        room.lastMessage!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis, // ✅ 메시지도 말줄임
                                      ),
                                    )
                                  : null,
                              trailing: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.logout,
                                        color: Colors.redAccent),
                                    tooltip: '채팅방 나가기',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("채팅방 나가기"),
                                          content: const Text("정말로 나가시겠습니까?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text("취소"),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text("나가기"),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        final success = await ref
                                            .read(chatRoomListProvider.notifier)
                                            .leaveChatRoom(room.fundingId);

                                        if (success) {
                                          ref
                                              .read(
                                                  chatRoomListProvider.notifier)
                                              .refresh();
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('채팅방 나가기에 실패했습니다.')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final result = await context.push(
                                  '/chat/room/${room.fundingId}',
                                  extra: {'fundingTitle': room.title},
                                );

                                if (result == 'refresh') {
                                  ref
                                      .read(chatRoomListProvider.notifier)
                                      .refresh();
                                }
                              },
                            ),
                          ),
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
