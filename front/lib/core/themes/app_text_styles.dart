import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 공통 텍스트 스타일
/// 앱 전체에서 공통으로 사용되는 기본 텍스트 스타일
class AppTextStyles {
  // 기본 타이포그래피 (크기 기반)
  static TextStyle get heading1 => GoogleFonts.righteous(
        fontSize: 40,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGrey,
      );

  static TextStyle get heading2 => GoogleFonts.righteous(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGrey,
      );

  static TextStyle get heading3 => GoogleFonts.righteous(
        fontSize: 25,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGrey,
      );

  static TextStyle get heading4 => GoogleFonts.righteous(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGrey,
      );

  static TextStyle get body1 => GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGrey,
      );

  static TextStyle get body2 => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGrey,
      );

  static TextStyle get caption => GoogleFonts.righteous(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
      );

  // 버튼 텍스트 스타일
  static TextStyle get buttonText => GoogleFonts.robotoMono(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.17,
        color: AppColors.grey,
      );

  static TextStyle get smallButtonText => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      );

  // 폼 관련 스타일
  static TextStyle get formLabel => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
      );

  static TextStyle get formInput => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGrey,
      );

  static TextStyle get errorText => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.red,
      );

  // 앱바 텍스트 스타일
  static TextStyle get appBarTitle => GoogleFonts.righteous(
        fontSize: 25,
        fontWeight: FontWeight.w300,
        color: AppColors.black,
      );

  // 로고 스타일
  static TextStyle get logo => GoogleFonts.righteous(
        fontSize: 78,
        color: AppColors.primary,
        height: 1.24,
      );

  static TextStyle get logoSmall => GoogleFonts.righteous(
        fontSize: 40,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
      );

  // 에러 및 빈 상태 텍스트 스타일
  static TextStyle get emptyMessage => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.grey,
      );

  static TextStyle get body => GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.black,
      );
}

/// 홈/메인 화면 텍스트 스타일
class HomeTextStyles {
  static TextStyle get mainTitle => GoogleFonts.notoSans(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      );

  static TextStyle get time => GoogleFonts.notoSans(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.grey,
      );

  static TextStyle get totalFund => GoogleFonts.notoSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  static TextStyle get totalFundLabel => GoogleFonts.righteous(
        fontSize: 24,
        fontWeight: FontWeight.w300,
        color: Colors.grey[400],
      );

  // 추가된 스타일 - 금액 표시용
  static TextStyle get fundAmount => const TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: 0.5,
        color: AppColors.fundAmount,
      );

  // 추가된 스타일 - "원" 표시용
  static TextStyle get fundUnit => const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.normal,
        color: AppColors.fundAmount,
      );

  static TextStyle get topProjectTitle => GoogleFonts.righteous(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGrey,
      );

  static TextStyle get projectTitle => GoogleFonts.notoSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      );

  static TextStyle get projectDescription => GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.grey,
      );

  static TextStyle get projectLabel => const TextStyle(
        fontSize: 12,
        color: AppColors.grey,
      );

  static TextStyle get projectPercentage => GoogleFonts.righteous(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
      );

  static TextStyle get projectPrice => GoogleFonts.notoSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle get projectTime => GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.grey,
      );

  static TextStyle get timeStyle => GoogleFonts.righteous(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGrey,
      );
}

/// 스플래시 화면 텍스트 스타일
class SplashTextStyles {
  static TextStyle get text => GoogleFonts.righteous(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle get logo => GoogleFonts.righteous(
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
      );
}

/// 인증 관련 텍스트 스타일
class AuthTextStyles {
  static TextStyle get title => GoogleFonts.righteous(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );

  static TextStyle get appleButtonText => const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.19,
        color: AppColors.white,
      );
}

/// 네비게이션 바 텍스트 스타일
class NavTextStyles {
  static TextStyle get navBarText => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkGrey,
      );
}

/// 상세 페이지 텍스트 스타일
class DetailTextStyles {
  static TextStyle get title => GoogleFonts.righteous(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );
}

/// 위시리스트 화면 텍스트 스타일
class WishlistTextStyles {
  // 위시리스트 탭 스타일
  static TextStyle get tabSelected => const TextStyle(
        color: AppColors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get tabUnselected => TextStyle(
        color: AppColors.textMuted,
        fontSize: 15,
        fontWeight: FontWeight.normal,
      );

  // 위시리스트 카드 스타일
  static TextStyle get companyName => TextStyle(
        fontSize: 13,
        color: AppColors.textMuted,
      );

  static TextStyle get itemTitle => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get badge => const TextStyle(
        color: AppColors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get fundingPercentage => const TextStyle(
        fontSize: 16,
        color: AppColors.wishlistLiked,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get fundingAmount => TextStyle(
        fontSize: 13,
        color: AppColors.textMuted,
      );

  static TextStyle get participateButton => const TextStyle(
        color: AppColors.white,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      );

  // 빈 위시리스트 메시지
  static TextStyle get emptyMessage => TextStyle(
        fontSize: 16,
        color: AppColors.textMuted,
      );
}

/// 판매자(메이커) 화면 텍스트 스타일
class SellerTextStyles {
  // 판매자 프로필 스타일
  static TextStyle get sellerName => GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
      );

  static TextStyle get makerType => GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
      );

  static TextStyle get badge => const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  // 판매자 통계 스타일
  static TextStyle get statTitle => GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.grey,
      );

  static TextStyle get statValue => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
      );

  static TextStyle get statDetail => GoogleFonts.roboto(
        fontSize: 10,
        color: AppColors.grey,
      );

  // 탭 스타일
  static TextStyle get tabSelected => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );

  static TextStyle get tabUnselected => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.grey,
      );

  // 섹션 헤더 스타일
  static TextStyle get sectionTitle => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
      );

  // 프로젝트 컨텐츠 스타일
  static TextStyle get projectTitle => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
      );

  static TextStyle get emptyMessage => GoogleFonts.roboto(
        fontSize: 14,
        color: AppColors.grey,
      );

  // 리뷰 스타일
  static TextStyle get reviewUserName => GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
      );

  static TextStyle get reviewContent => GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.darkGrey,
      );

  static TextStyle get reviewProductName => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      );

  static TextStyle get reviewHeader => GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
      );

  static TextStyle get reviewStats => GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
      );
}
