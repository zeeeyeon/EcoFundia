import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/websocket_provider.dart';
import 'package:front/core/services/chat_room_storage_service.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/ui/widgets/custom_app_bar.dart';
import 'package:front/features/chat/providers/chat_repository_provider.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String _connectionStatus = '⏳ WebSocket 연결 시도 중...';
  List<Map<String, dynamic>> _chatRooms = [];

  @override
  void initState() {
    super.initState();
    _tryConnectWebSocket();
    _loadChatRooms();
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

  Future<void> _loadChatRooms() async {
    final rooms = await ChatRoomStorageService.getJoinedFundings();
    // 🔍 로컬 저장소 확인용 로그
    print('📦 저장된 채팅방 목록 (Storage): $rooms');
    setState(() {
      _chatRooms = rooms;
    });
  }

  Future<void> _leaveRoom(int fundingId) async {
    final repo = ref.read(chatRepositoryProvider);

    final success = await repo.leaveChat(fundingId);
    if (success) {
      await ChatRoomStorageService.removeJoinedFunding(fundingId);
      await _loadChatRooms();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('채팅방 나가기에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: _chatRooms.isEmpty
                ? const Center(child: Text('참여 중인 채팅방이 없습니다.'))
                : ListView.separated(
                    itemCount: _chatRooms.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final room = _chatRooms[index];
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.logout,
                                    color: Colors.redAccent),
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
                                    await _leaveRoom(room['fundingId']);
                                  }
                                },
                              ),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.primary),
                            ],
                          ),
                          onTap: () async {
                            final result = await context.push(
                              '/chat/room/${room['fundingId']}',
                              extra: {'fundingTitle': room['fundingTitle']},
                            );

                            if (result == 'refresh') {
                              print('🔁 채팅방 목록 새로고침 중...');
                              await _loadChatRooms(); // ✅ 이거 안 하면 UI 갱신 안 됨
                            }
                          });
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
