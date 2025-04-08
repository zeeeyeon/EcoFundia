import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/core/ui/widgets/loading_overlay.dart';
import 'package:front/core/ui/widgets/login_required_modal.dart';
import 'package:front/features/mypage/ui/view_model/total_funding_provider.dart';
import 'package:front/features/mypage/ui/view_model/coupon_view_model.dart';
import 'package:front/features/mypage/ui/widgets/funding_status_card.dart';
import 'package:front/features/mypage/ui/widgets/mypage_support_section.dart';
import 'package:front/utils/logger_util.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import '../view_model/profile_view_model.dart';
import '../widgets/profile_card.dart';
import '../widgets/greeting_message.dart';

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

    // 로그인하지 않은 경우 로그인 안내 화면 표시
    if (!isLoggedIn) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: "My Page",
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle_outlined,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                '로그인이 필요한 서비스입니다',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '로그인하시면 마이페이지와 쿠폰 서비스를\n이용하실 수 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.push('/login');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                ),
                child: const Text('로그인 하기'),
              ),
            ],
          ),
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
