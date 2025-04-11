import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatRoomStorageService {
  static const _storage = FlutterSecureStorage();
  static const _chatRoomsKey = 'joinedChatRooms';

  /// 채팅방 추가
  static Future<void> addJoinedFunding(int fundingId, String title) async {
    final rooms = await getJoinedFundings();
    final isAlreadyJoined = rooms.any((room) => room['fundingId'] == fundingId);

    if (!isAlreadyJoined) {
      rooms.add({
        'fundingId': fundingId,
        'fundingTitle': title,
      });
      await _storage.write(
        key: _chatRoomsKey,
        value: jsonEncode(rooms),
      );
    }
  }

  /// 채팅방 삭제
  static Future<void> removeJoinedFunding(int fundingId) async {
    final rooms = await getJoinedFundings();
    final updated =
        rooms.where((room) => room['fundingId'] != fundingId).toList();
    await _storage.write(
      key: _chatRoomsKey,
      value: jsonEncode(updated),
    );
  }

  /// 참여한 채팅방 전체 조회
  static Future<List<Map<String, dynamic>>> getJoinedFundings() async {
    final raw = await _storage.read(key: _chatRoomsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    return List<Map<String, dynamic>>.from(decoded);
  }
}
