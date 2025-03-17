import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get logo => GoogleFonts.righteous(
        fontSize: 78,
        color: AppColors.primary,
        height: 1.24,
      );

  static TextStyle get buttonText => GoogleFonts.roboto(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.17,
        color: AppColors.textGrey,
      );

  static TextStyle get appleButtonText => const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.19,
        color: AppColors.white,
      );

  // ✅ **메인 페이지 스타일**
  static TextStyle get mainTitle => GoogleFonts.righteous(
        fontSize: 40,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGrey,
      );

  static TextStyle get totalFund => GoogleFonts.righteous(
        fontSize: 40,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
      );

  static TextStyle get totalFundLabel => GoogleFonts.righteous(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.grey,
      );

  static TextStyle get topProjectTitle => GoogleFonts.righteous(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGrey,
      );

  static TextStyle get projectTitle => const TextStyle(
        fontFamily: 'Space Grotesk',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.darkGrey,
      );

  static TextStyle get projectDescription => const TextStyle(
        fontFamily: 'Space Grotesk',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkGrey,
      );

  static TextStyle get projectLabel => const TextStyle(
        fontSize: 12,
        color: AppColors.grey,
      );

  static TextStyle get projectPercentage => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
      );

  static TextStyle get projectPrice => const TextStyle(
        fontSize: 15,
        color: AppColors.grey,
      );

  static TextStyle get timeStyle => GoogleFonts.righteous(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGrey,
      );

  // ✅ **🆕 스플래시 화면 스타일**
  static TextStyle get splashText => GoogleFonts.righteous(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  // ✅ **🆕 스플래시 화면 스타일(로고)**
  static TextStyle get splashLogo => GoogleFonts.righteous(
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
      );

  // ✅ **🆕 네비게이션 바 스타일**
  static TextStyle get navBarText => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkGrey,
      );

  // ✅ **🆕 상세 페이지 제목 스타일**
  static TextStyle get detailTitle => GoogleFonts.righteous(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );

  // ✅ **🆕 에러 메시지 스타일**
  static TextStyle get errorText => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.red,
      );

  // ✅ **🆕 폼 필드 라벨 스타일**
  static TextStyle get formLabel => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
      );

  // ✅ **🆕 작은 텍스트 스타일**
  static TextStyle get smallText => GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textGrey,
      );
}
