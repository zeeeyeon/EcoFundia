import 'package:flutter/material.dart';
import 'package:front/features/mypage/ui/pages/profile_edit_screen.dart';
import 'package:front/features/mypage/ui/pages/support/faq_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/mypage/ui/pages/mypage_screen.dart';
import 'package:front/features/mypage/ui/pages/my_funding_screen.dart';
import 'package:front/features/mypage/ui/pages/my_review_screen.dart';
import 'package:front/features/mypage/ui/pages/write_review_screen.dart';
import 'package:front/features/mypage/ui/pages/edit_review_screen.dart';
import 'package:front/features/mypage/ui/pages/coupons_screen.dart';
// import 'package:front/features/mypage/ui/pages/profile_edit_screen.dart'; // TODO: 필요시 활성화

// 마이페이지 탭 라우트 브랜치 생성 함수
StatefulShellBranch createMypageBranch(GlobalKey<NavigatorState> navigatorKey) {
  return StatefulShellBranch(
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: '/mypage',
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            key: ValueKey('mypage'),
            child: MypageScreen(),
          );
        },
        routes: [
          GoRoute(
            path: 'my-funding',
            builder: (context, state) => const MyFundingScreen(),
          ),
          GoRoute(
            path: 'my-reviews',
            builder: (context, state) => const MyReviewScreen(),
          ),
          GoRoute(
            path: 'review/write/:fundingId',
            builder: (context, state) {
              final fundingId =
                  int.parse(state.pathParameters['fundingId'] ?? '0');
              final extra = state.extra as Map<String, dynamic>?;
              return WriteReviewScreen(
                fundingId: fundingId,
                title: extra?['title'] ?? '',
                description: extra?['description'] ?? '',
                totalPrice: extra?['totalPrice'] ?? 0,
              );
            },
          ),
          GoRoute(
            path: 'review/edit/:reviewId',
            builder: (context, state) {
              final reviewId =
                  int.parse(state.pathParameters['reviewId'] ?? '0');
              final extra = state.extra as Map<String, dynamic>?;
              return EditReviewScreen(
                reviewId: reviewId,
                initialRating: extra?['initialRating'] ?? 5,
                initialContent: extra?['initialContent'] ?? '',
                title: extra?['title'] ?? '',
                description: extra?['description'] ?? '',
                totalPrice: extra?['totalPrice'] ?? 0,
              );
            },
          ),
          GoRoute(
            path: 'coupons',
            builder: (context, state) => const CouponsScreen(),
          ),
          // TODO: Add profile edit route -> 하위 경로로 이동 및 path 수정
          GoRoute(
            path: 'profile-edit', // '/' 제거
            builder: (context, state) => const ProfileEditScreen(),
          ),
          GoRoute(
            path: 'faq', // '/' 제거
            builder: (context, state) => const FaqScreen(),
          ),
        ],
      ),
    ],
  );
}
