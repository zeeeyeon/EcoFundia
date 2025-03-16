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
}
