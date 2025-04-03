import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';

class ChatRoomScreen extends StatelessWidget {
  final int fundingId;
  final String fundingTitle;

  const ChatRoomScreen({
    super.key,
    required this.fundingId,
    required this.fundingTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅방: $fundingTitle (#$fundingId)'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: const [
                _ChatBubble(
                  isMine: false,
                  message: "안녕하세요! 이 펀딩 너무 좋아 보여요 😍",
                  timestamp: "오전 10:12",
                ),
                _ChatBubble(
                  isMine: true,
                  message: "저도요! 얼른 목표 달성했으면 좋겠네요",
                  timestamp: "오전 10:14",
                ),
                _ChatBubble(
                  isMine: false,
                  message: "혹시 배송은 언제쯤 시작되나요?",
                  timestamp: "오전 10:15",
                ),
              ],
            ),
          ),
          const _ChatInputField(),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final bool isMine;
  final String message;
  final String timestamp;

  const _ChatBubble({
    required this.isMine,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMine ? 12 : 0),
            bottomRight: Radius.circular(isMine ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMine ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timestamp,
              style: TextStyle(
                fontSize: 10,
                color: isMine ? Colors.white70 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatInputField extends StatelessWidget {
  const _ChatInputField();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요',
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 22,
            child: Icon(Icons.send, color: Colors.white),
          )
        ],
      ),
    );
  }
}
