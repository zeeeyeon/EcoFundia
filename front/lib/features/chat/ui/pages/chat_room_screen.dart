import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';

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

  final List<Map<String, dynamic>> _messages = [
    {'fromMe': false, 'text': '이 펀딩 너무 좋아 보여요!'},
    {'fromMe': true, 'text': '저도 관심 있어서 들어왔어요 :)'},
    {'fromMe': false, 'text': '목표 금액 거의 달성했네요 🎉'},
  ];

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅방: ${widget.fundingTitle} (#${widget.fundingId})'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 🔼 메시지 목록
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final fromMe = msg['fromMe'] as bool;
                final text = msg['text'] as String;

                return Align(
                  alignment:
                      fromMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
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
                );
              },
            ),
          ),

          // 🔽 입력창
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
