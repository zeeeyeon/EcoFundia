import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/app_state_provider.dart';
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

    if (!isLoggedIn) {
      return _buildLoggedOutView();
    }

    final profileState = ref.watch(profileProvider);
    final totalFundingState = ref.watch(totalFundingAmountProvider);
    final couponState = ref.watch(couponViewModelProvider);

    // 프로필 또는 총 펀딩 금액 로딩 중일 때 로컬 로딩 인디케이터 표시
    if (profileState is AsyncLoading || totalFundingState is AsyncLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 에러 처리 (하나라도 에러 발생 시)
    if (profileState is AsyncError || totalFundingState is AsyncError) {
      final error = profileState is AsyncError
          ? profileState.error
          : (totalFundingState as AsyncError).error;
      final stackTrace = profileState is AsyncError
          ? profileState.stackTrace
          : (totalFundingState as AsyncError).stackTrace;

      LoggerUtil.e('마이페이지 데이터 로딩 에러', error, stackTrace);

      return Scaffold(
          appBar: _buildAppBar(),
          body: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              const Text('데이터를 불러오는데 실패했습니다.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(profileProvider);
                  ref.invalidate(totalFundingAmountProvider);
                  // 필요하다면 쿠폰도 다시 로드
                  if (ref.read(isLoggedInProvider)) {
                    ref
                        .read(couponViewModelProvider.notifier)
                        .loadCouponCount(forceRefresh: true);
                  }
                },
                child: const Text('다시 시도'),
              ),
            ],
          )));
    }

    // 데이터 성공적으로 로드 완료
    final profile = profileState.value;
    final totalAmount = totalFundingState.value;

    if (profile == null || totalAmount == null) {
      // 이론상 여기까지 오면 안되지만, 방어 코드
      return Scaffold(
          appBar: _buildAppBar(),
          body: const Center(child: Text('데이터가 유효하지 않습니다.')));
    }

    // 쿠폰 개수는 couponState.couponCount 로 접근
    final currentCouponCount = couponState.couponCount;

    return Scaffold(
      appBar: _buildAppBar(couponCount: currentCouponCount),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
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
    );
  }

  Widget _buildLoggedOutView() {
    // 로그인하지 않은 경우 로그인 안내 화면 표시 -> 로그인 페이지로 리디렉션
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

  AppBar _buildAppBar({int? couponCount}) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'My Page',
        style: AppTextStyles.appBarTitle,
      ),
      backgroundColor: AppColors.white,
      elevation: 0,
      actions: [
        // 설정 버튼
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.grey),
          onPressed: () {
            // TODO: 설정 화면 구현
            LoggerUtil.d('⚙️ 설정 버튼 클릭');
            context.push('/coming-soon');
          },
          tooltip: '설정',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
