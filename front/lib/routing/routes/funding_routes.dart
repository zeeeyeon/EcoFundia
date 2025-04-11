import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/funding/ui/pages/funding_list_screen.dart';
import 'package:front/features/funding/ui/pages/search_screen.dart';

// 펀딩 탭 라우트 브랜치 생성 함수 (navigatorKey를 파라미터로 받음)
StatefulShellBranch createFundingBranch(
    GlobalKey<NavigatorState> navigatorKey) {
  return StatefulShellBranch(
    navigatorKey: navigatorKey, // 파라미터로 받은 키 사용
    routes: [
      GoRoute(
        path: '/funding',
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            key: ValueKey('funding'),
            child: FundingListScreen(),
          );
        },
        routes: [
          GoRoute(
            path: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
        ],
      ),
    ],
  );
}
