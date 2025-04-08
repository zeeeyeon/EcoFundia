import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/websocket_provider.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/core/services/websocket_manager.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/features/chat/data/models/chat_model.dart';
import 'package:front/features/chat/ui/view_model/chat_view_model.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final int fundingId;
  final String fundingTitle;

  const ChatRoomScreen({
    super.key,
    required this.fundingId,
    required this.fundingTitle,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final WebSocketManager _wsManager;
  late int _userId;

  @override
  void initState() {
    super.initState();
    _wsManager = ref.read(websocketManagerProvider);
    _initializeChatRoom();
  }

  Future<void> _initializeChatRoom() async {
    final token = await StorageService.getToken();
    final userIdStr = await StorageService.getUserId();
    _userId = int.tryParse(userIdStr ?? '0') ?? 0;

    if (!_wsManager.isConnected) {
      _wsManager.connect(
        userToken: token!,
        onConnectCallback: (_) {
          if (!mounted) return;
          _subscribe();
        },
      );
    } else {
      _subscribe();
    }
  }

  void _subscribe() {
    final destination = '/sub/chat/${widget.fundingId}';
    debugPrint('📡 채팅방 구독 요청 → $destination (userId: $_userId)');

    _wsManager.subscribeToRoom(
      fundingId: widget.fundingId,
      userId: _userId,
      onMessage: (StompFrame frame) {
        if (frame.body == null) {
          debugPrint('⚠️ 수신된 메시지 body가 null입니다.');
          return;
        }

        debugPrint('📩 [Raw 메시지 수신] body: ${frame.body}');

        try {
          final data = jsonDecode(frame.body!);

          final senderId = data['senderId'];
          final nickname = data['nickname'] ?? '익명';
          final content = data['content'];
          final createdAtString = data['createdAt'];
          final createdAt = createdAtString != null
              ? DateTime.tryParse(createdAtString)
              : DateTime.now();

          final newMessage = ChatMessage(
            senderId: senderId,
            nickname: nickname,
            content: content,
            createdAt: createdAt!,
          );

          ref
              .read(chatRoomViewModelProvider(widget.fundingId).notifier)
              .addMessage(newMessage);
        } catch (e) {
          debugPrint('❌ JSON 파싱 오류: $e');
        }
      },
    );
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final nickname = await StorageService.getNickname();

    _wsManager.sendMessageToRoom(
      fundingId: widget.fundingId,
      senderId: _userId,
      nickname: nickname ?? '익명',
      content: text,
      createdAt: DateTime.now(),
    );

    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatRoomViewModelProvider(widget.fundingId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '채팅방: ${widget.fundingTitle} (#${widget.fundingId})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final fromMe = msg.senderId == _userId;

                final formattedTime =
                    TimeOfDay.fromDateTime(msg.createdAt).format(context);

                return Align(
                  alignment:
                      fromMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: fromMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (!fromMe && msg.nickname.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 2),
                          child: Text(
                            msg.nickname,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: fromMe
                              ? AppColors.primary.withOpacity(0.9)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(fromMe ? 12 : 0),
                            bottomRight: Radius.circular(fromMe ? 0 : 12),
                          ),
                        ),
                        child: Text(
                          msg.content,
                          style: TextStyle(
                            color: fromMe ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 2, left: 8, right: 8),
                        child: Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
