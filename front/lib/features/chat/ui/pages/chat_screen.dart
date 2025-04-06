import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/websocket_provider.dart';
import '../../../../core/services/storage_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String _connectionStatus = '⏳ WebSocket 연결 중...';

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  Future<void> _connectToWebSocket() async {
    final token = await StorageService.getToken(); // JWT 불러오기
    if (token == null) {
      setState(() => _connectionStatus = '❌ 토큰 없음');
      return;
    }

    final wsManager = ref.read(websocketManagerProvider);
    wsManager.connect(
      userToken: token,
      onConnectCallback: (frame) {
        setState(() {
          _connectionStatus = '✅ WebSocket 연결 성공!';
        });
        print('✅ WebSocket 연결 성공! headers: ${frame.headers ?? '없음'}');
      },
      onError: (error) {
        setState(() {
          _connectionStatus = '❌ WebSocket 연결 실패: $error';
        });
        print('❌ WebSocket 연결 실패: $error');
      },
    );
  }

  @override
  void dispose() {
    ref.read(websocketManagerProvider).disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: Colors.grey[200],
            child: Text(_connectionStatus),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
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
          ),
        ],
      ),
    );
  }
}
