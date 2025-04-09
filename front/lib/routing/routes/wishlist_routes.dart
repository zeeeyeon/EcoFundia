import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/wishlist/ui/pages/wishlist_screen.dart';

// 위시리스트 탭 라우트 브랜치 생성 함수
StatefulShellBranch createWishlistBranch(
    GlobalKey<NavigatorState> navigatorKey) {
  return StatefulShellBranch(
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: '/wishlist',
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            key: ValueKey('wishlist'),
            child: WishlistScreen(),
          );
        },
      ),
    ],
  );
}
