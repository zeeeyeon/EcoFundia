class ChatMessage {
  final int senderId;
  final String nickname;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.senderId,
    required this.nickname,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderId: json['senderId'] as int,
      nickname: json['nickname'] ?? '익명',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'nickname': nickname,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
