class ChatRoom {
  final String chatRoomId;
  final int fundingId;
  final String title;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  ChatRoom({
    required this.chatRoomId,
    required this.fundingId,
    required this.title,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      chatRoomId: json['chatRoomId'],
      fundingId: json['fundingId'],
      title: json['title'],
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'])
          : null,
    );
  }
}
