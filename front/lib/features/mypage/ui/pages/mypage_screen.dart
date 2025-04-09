import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/core/ui/widgets/loading_overlay.dart';
import 'package:front/features/mypage/ui/view_model/total_funding_provider.dart';
import 'package:front/features/mypage/ui/view_model/coupon_view_model.dart';
import 'package:front/features/mypage/ui/widgets/funding_status_card.dart';
import 'package:front/features/mypage/ui/widgets/my_page_support_section.dart';
import 'package:front/utils/logger_util.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import '../view_model/profile_view_model.dart';
import '../widgets/profile_card.dart';

class MypageScreen extends ConsumerStatefulWidget {
  const MypageScreen({super.key});

  @override
  ConsumerState<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends ConsumerState<MypageScreen> {
  @override
  void initState() {
    super.initState();
    // 마이페이지 진입 시 쿠폰 개수를 확실하게 갱신
    _refreshCouponCount();
  }

  // 쿠폰 개수 강제 새로고침
  void _refreshCouponCount() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(isLoggedInProvider)) {
        LoggerUtil.d('🎫 마이페이지: 쿠폰 개수 강제 새로고침 요청');
        ref
            .read(couponViewModelProvider.notifier)
            .loadCouponCount(forceRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 로그인 상태 확인
    final isLoggedIn = ref.watch(isLoggedInProvider);

    // 로그인하지 않은 경우 로그인 안내 화면 표시 -> 로그인 페이지로 리디렉션
    if (!isLoggedIn && context.mounted) {
      // context.mounted 확인 추가
      // 빌드 완료 후 리디렉션 수행
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 현재 화면을 대체하여 로그인 페이지로 이동 (뒤로가기 시 마이페이지로 돌아오지 않도록)
        context.pushReplacement('/login');
        LoggerUtil.d('🔒 마이페이지 접근 시 로그인 상태 아님 확인 -> 로그인 페이지로 리디렉션');
      });

      // 리디렉션 전 임시 화면 (빈 화면 또는 로딩 인디케이터)
      return const Scaffold(
        body: Center(
          // child: CircularProgressIndicator(), // 로딩 표시 원할 경우
          child: SizedBox.shrink(), // 빈 화면
        ),
      );
    }

    // 로그인된 경우 기존 마이페이지 화면 표시
    final profileState = ref.watch(profileProvider);
    final totalFundingState = ref.watch(totalFundingAmountProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "My Page",
          style: AppTextStyles.appBarTitle.copyWith(color: AppColors.textDark),
        ),
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 1,
        shadowColor: AppColors.shadowColor.withOpacity(0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined,
                color: AppColors.textDark),
            onPressed: () {
              // TODO: Navigate to cart or related page
              // context.push('/cart');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined,
                color: AppColors.textDark),
            onPressed: () {
              context.push('/notifications');
            },
          ),
          IconButton(
            icon:
                const Icon(Icons.settings_outlined, color: AppColors.textDark),
            onPressed: () {
              context.push('/settings');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LoadingOverlay(
        isLoading: profileState.isLoading || totalFundingState.isLoading,
        child: profileState.when(
          loading: () => const SizedBox.shrink(), // 화면은 안 보이고 로딩만
          error: (err, _) => Center(child: Text("오류 발생: $err")),
          data: (profile) => totalFundingState.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Center(child: Text("펀딩 금액 로딩 실패: $e")),
            data: (totalAmount) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileCard(profile: profile),
                  FundingStatusCard(
                    totalFundingAmount: totalAmount,
                  ),
                  const CustomerSupportSection(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
