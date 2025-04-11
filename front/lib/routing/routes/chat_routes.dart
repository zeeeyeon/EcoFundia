import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/chat/ui/pages/chat_screen.dart';

// 채팅 탭 라우트 브랜치 생성 함수
StatefulShellBranch createChatBranch(GlobalKey<NavigatorState> navigatorKey) {
  return StatefulShellBranch(
    navigatorKey: navigatorKey,
    routes: [
      // Chat List Screen remains in the branch
      GoRoute(
        path: '/chat',
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            key: ValueKey('chat'),
            child: ChatScreen(),
          );
        },
      ),
    ],
  );
}
