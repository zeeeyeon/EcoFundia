import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/constants/app_sizes.dart';
import 'package:front/core/themes/app_shadows.dart';
import 'package:front/features/home/ui/widgets/project_carousel.dart';
import 'package:front/features/home/ui/view_model/project_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/features/home/ui/widgets/current_time_display.dart';
import 'package:front/features/home/ui/widgets/total_fund_display.dart';

/// 홈 화면 위젯
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectViewModelProvider.notifier).loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    // 고정된 캐러셀 기본 높이 (ProjectCarousel과 일치)
    const baseCarouselHeight = 600;
    final scaleFactor = isSmallScreen ? 0.85 : 1.0;

    // ProjectCarousel의 내부 계산값과 일치시킴
    final carouselContainerHeight = baseCarouselHeight * scaleFactor * 0.97;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false, // 바텀 오버플로우 방지
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // 상단 정보 컨테이너 (SIMPLE 로고, 현재 시간, 총 펀드 금액)
              _buildTopInfoContainer(),

              // 간격 추가
              const SizedBox(height: 8),

              // 프로젝트 캐러셀
              SizedBox(
                height: carouselContainerHeight,
                child: Consumer(
                  builder: (context, ref, _) {
                    final projectState = ref.watch(projectViewModelProvider);

                    if (projectState.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (projectState.error != null) {
                      return Center(child: Text(projectState.error!));
                    }

                    return ProjectCarousel(
                      projects: projectState.projects,
                      onPurchaseTap: (project) {
                        // 펀딩하기 버튼 클릭 시 상세 페이지로 이동
                        context.push('/project/${project.id}',
                            extra: {'project': project});
                      },
                      onLikeTap: (project) {
                        ref
                            .read(projectViewModelProvider.notifier)
                            .toggleLike(project);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 상단 정보 컨테이너 위젯
  Widget _buildTopInfoContainer() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: AppSizes.spacingM / 2,
      ),
      padding: const EdgeInsets.all(AppSizes.paddingL / 1.5),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [AppShadows.card],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 로고 텍스트
          Text(
            AppStrings.appName,
            style: AppTextStyles.heading2.copyWith(
              letterSpacing: 3,
              color: AppColors.primary,
            ),
          ),

          // 현재 시간 표시
          const CurrentTimeDisplay(),

          const SizedBox(height: AppSizes.spacingM),

          // 총 펀드 금액 표시
          const TotalFundDisplay(),
        ],
      ),
    );
  }
}
