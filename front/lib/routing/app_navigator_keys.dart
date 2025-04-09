import 'package:flutter/material.dart';

// 정적으로 선언된 GlobalKey - 싱글턴으로 관리
class AppNavigatorKeys {
  // 싱글턴 패턴 구현
  static final AppNavigatorKeys _instance = AppNavigatorKeys._();
  static AppNavigatorKeys get instance => _instance;
  AppNavigatorKeys._();

  // 루트 네비게이터 키
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  // 쉘 네비게이터 키
  final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  // 각 탭별 네비게이터 키
  final fundingTabKey = GlobalKey<NavigatorState>(debugLabel: 'funding_tab');
  final homeTabKey = GlobalKey<NavigatorState>(debugLabel: 'home_tab');
  final wishlistTabKey = GlobalKey<NavigatorState>(debugLabel: 'wishlist_tab');
  final mypageTabKey = GlobalKey<NavigatorState>(debugLabel: 'mypage_tab');
  final chatTabKey = GlobalKey<NavigatorState>(debugLabel: 'chat_tab');
}
