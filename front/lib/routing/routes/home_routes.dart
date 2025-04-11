import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/home/ui/pages/home_screen.dart';

// 홈 탭 라우트 브랜치 생성 함수
StatefulShellBranch createHomeBranch(GlobalKey<NavigatorState> navigatorKey) {
  return StatefulShellBranch(
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            key: ValueKey('home'),
            child: HomeScreen(),
          );
        },
      ),
    ],
  );
}
