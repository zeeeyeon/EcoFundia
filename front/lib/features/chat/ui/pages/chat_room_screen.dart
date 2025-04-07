import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/services/websocket_manager.dart'; // WebSocketManager는 따로 만든 파일이어야 해

class ChatRoomScreen extends StatefulWidget {
  final int fundingId;
  final String fundingTitle;

  const ChatRoomScreen({
    super.key,
    required this.fundingId,
    required this.fundingTitle,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final WebSocketManager _webSocketManager = WebSocketManager();

  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _initWebSocketConnection();
  }

  Future<void> _initWebSocketConnection() async {
    final token = await StorageService.getToken();
    final userIdStr = await StorageService.getUserId();
    final userId = int.tryParse(userIdStr ?? '0') ?? 0;

    _webSocketManager.connect(
      userToken: token!,
      onConnectCallback: (frame) {
        print('✅ WebSocket 연결 성공');

        _webSocketManager.subscribeToRoom(
          fundingId: widget.fundingId,
          userId: userId,
          onMessage: (frame) {
            print('📩 메시지 수신: ${frame.body}');

            try {
              final data = jsonDecode(frame.body!);
              final content = data['content'];

              setState(() {
                _messages.add({
                  'fromMe': false,
                  'nickname': '서버',
                  'text': '예정 정산 금액: ${content['expectedAmount']}원',
                });
              });
            } catch (e) {
              print('❌ 메시지 파싱 오류: $e');
            }
          },
        );
      },
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'fromMe': true, 'text': text});
    });

    _messageController.clear();

    // 스크롤 아래로 이동
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
    _webSocketManager.disconnect();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '채팅방: ${widget.fundingTitle} (#${widget.fundingId})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final fromMe = msg['fromMe'] as bool;
                final text = msg['text'] as String;
                final nickname = msg['nickname'] as String?;

                return Align(
                  alignment:
                      fromMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: fromMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (!fromMe && nickname != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 2),
                          child: Text(
                            nickname,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
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
                          text,
                          style: TextStyle(
                            color: fromMe ? Colors.white : Colors.black87,
                            fontSize: 14,
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
