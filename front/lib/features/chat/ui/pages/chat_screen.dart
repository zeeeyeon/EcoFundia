import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/ui/widgets/custom_app_bar.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/websocket_provider.dart';
import '../../../../core/services/storage_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String _connectionStatus = '⏳ WebSocket 연결 시도 중...';

  @override
  void initState() {
    super.initState();
    _tryConnectWebSocket();
  }

  Future<void> _tryConnectWebSocket() async {
    final token = await StorageService.getToken();
    if (token == null) {
      setState(() => _connectionStatus = '❌ 토큰 없음');
      return;
    }

    final wsManager = ref.read(websocketManagerProvider);

    if (!wsManager.isConnected) {
      wsManager.connect(
        userToken: token,
        onConnectCallback: (frame) {
          setState(() {
            _connectionStatus = '✅ WebSocket 연결 성공!';
          });
          print('✅ WebSocket 연결 성공: ${frame.headers}');
        },
        onError: (error) {
          setState(() {
            _connectionStatus = '❌ 연결 실패: $error';
          });
          print('❌ WebSocket 연결 실패: $error');
        },
      );
    } else {
      setState(() {
        _connectionStatus = '✅ 이미 연결됨';
      });
    }
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
      appBar: const CustomAppBar(title: "My Chats"),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: Colors.grey[200],
            child: Text(
              _connectionStatus,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: mockRooms.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final room = mockRooms[index];
                return ListTile(
                  leading: const Icon(Icons.forum_outlined,
                      color: AppColors.primary),
                  title: Text(
                    room['fundingTitle']?.toString() ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    room['lastMessage']?.toString() ?? '',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: AppColors.primary),
                  onTap: () {
                    context.push(
                      '/chat/room/${room['fundingId']}',
                      extra: {'fundingTitle': room['fundingTitle']},
                    );
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
