import 'package:flutter/material.dart';

/// 앱 전체에서 사용할 그림자 스타일 정의
class AppShadows {
  /// 카드에 사용할 기본 그림자
  static const BoxShadow card = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.08),
    blurRadius: 10.0,
    spreadRadius: 0.0,
    offset: Offset(0, 4),
  );

  /// 버튼에 사용할 그림자
  static const BoxShadow button = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    blurRadius: 6.0,
    spreadRadius: 0.0,
    offset: Offset(0, 2),
  );

  /// 바텀 내비게이션에 사용할 그림자
  static const BoxShadow bottomNavigation = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.12),
    blurRadius: 8.0,
    spreadRadius: 0.0,
    offset: Offset(0, -2),
  );

  /// 팝업에 사용할 강한 그림자
  static const BoxShadow popup = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.15),
    blurRadius: 15.0,
    spreadRadius: 1.0,
    offset: Offset(0, 5),
  );
}
