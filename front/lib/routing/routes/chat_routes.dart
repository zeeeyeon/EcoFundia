import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/chat/ui/pages/chat_screen.dart';
import 'package:front/features/chat/ui/pages/chat_room_screen.dart';
import 'package:front/core/ui/page/coming_soon_screen.dart';

// 채팅 탭 라우트 브랜치 생성 함수
StatefulShellBranch createChatBranch(GlobalKey<NavigatorState> navigatorKey) {
  return StatefulShellBranch(
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: '/chat',
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            key: ValueKey('chat'),
            child: ChatScreen(),
          );
        },
      ),
      GoRoute(
        path: '/chat/room/:fundingId',
        name: 'chatRoom',
        builder: (context, state) {
          final fundingId =
              int.tryParse(state.pathParameters['fundingId'] ?? '');
          final extra = state.extra as Map<String, dynamic>?;
          if (fundingId == null) return const ComingSoonScreen(); // ID 파싱 실패 시
          return ChatRoomScreen(
            fundingId: fundingId,
            fundingTitle: extra?['title'] ?? '펀딩',
          );
        },
      ),
    ],
  );
}
