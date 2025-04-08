import 'package:flutter/material.dart';

/// 앱에서 사용되는 색상 정의
class AppColors {
  // 기본 색상
  static const white = Colors.white;
  static const black = Colors.black;
  static const transparent = Colors.transparent;
  static const primary = Color(0xFFA3D80D);

  // 그레이 스케일
  static const darkGrey = Color(0xFF4A4A4A);
  static const grey = Color(0xFF979796);
  static const lightGrey = Color(0xFFCCCCCC);
  static const extraLightGrey = Color(0xFFF5F5F5);

  // 추가: Figma에서 자주 사용되는 텍스트 색상 (#171816)
  static const textDark = Color(0xFF171816);

  // 테마 색상
  static const mainColor = Color(0x009db2ce);
  static const error = Colors.red;
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFA000);

  // 위시리스트 관련 색상
  static const wishlistLiked = error; // 빨간색 재사용
  static final border = Colors.grey.shade300;
  static final shadowLight = Colors.black.withOpacity(0.1);
  static final textMuted = Colors.grey.shade600;

  // 그림자 색상
  static const shadowColor = Color(0x2B000000);
  static const shadowColorLight = Color(0x14000000);

  // 텍스트 필드 색상
  static const textFieldColor = extraLightGrey;
  static const textFieldTextColor = Color(0xFF171816);

  static const Color background = Color(0xFFF5F5F5);

  // TOTAL FUND 관련 색상
  static const Color fundAmount = Color(0xFFACE33B); // 연두색 금액 표시 색상
  static final Color fundBoxShadow =
      Colors.grey.withOpacity(0.2); // 금액 표시 박스 그림자 색상
}
