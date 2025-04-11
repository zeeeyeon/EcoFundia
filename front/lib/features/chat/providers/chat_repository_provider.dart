import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/websocket_provider.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/features/chat/data/repositories/chat_repository.dart';
import 'package:front/features/chat/data/services/chat_service.dart';

final chatServiceProvider = Provider((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ChatService(apiService);
});

final chatRepositoryProvider = Provider((ref) {
  final service = ref.read(chatServiceProvider);
  final ws = ref.read(websocketManagerProvider);
  return ChatRepository(service, ws);
});
