import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 👇 임시 채팅방 데이터
    final mockRooms = [
      {
        'fundingId': 3,
        'fundingTitle': '제로웨이스트 텀블러',
        'lastMessage': '언제 배송되나요?'
      },
      {'fundingId': 5, 'fundingTitle': '에코백 프로젝트', 'lastMessage': '좋은 프로젝트네요!'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('채팅 목록')),
      body: ListView.separated(
        itemCount: mockRooms.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final room = mockRooms[index];
          return ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: Text(room['fundingTitle']?.toString() ?? ''),
            subtitle: Text(room['lastMessage']?.toString() ?? ''),
            onTap: () {
              context.push('/chat/room/${room['fundingId']}', extra: {
                'fundingTitle': room['fundingTitle'],
              });
            },
          );
        },
      ),
    );
  }
}
