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

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  DateTime? _lastLoadTime;
  final bool _isPageVisible = true;

  @override
  bool get wantKeepAlive => false; // 탭 이동 시 항상 재로드하기 위해 false로 설정

  @override
  void initState() {
    super.initState();
    // 앱 라이프사이클 옵저버 등록
    WidgetsBinding.instance.addObserver(this);

    // Future.microtask를 사용하여 위젯 빌드 사이클 이후에 실행
    Future.microtask(() {
      _loadData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 포그라운드로 돌아오는 경우
    if (state == AppLifecycleState.resumed && _isPageVisible) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 사용 시 필요

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    // 고정된 캐러셀 기본 높이 (ProjectCarousel과 일치)
    const baseCarouselHeight = 600;
    final scaleFactor = isSmallScreen ? 0.85 : 1.0;

    // ProjectCarousel의 내부 계산값과 일치시킴
    final carouselContainerHeight = baseCarouselHeight * scaleFactor * 0.97;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false, // 바텀 오버플로우 방지
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // 상단 정보 컨테이너 (SIMPLE 로고, 현재 시간, 총 펀드 금액)
                _buildTopInfoContainer(),

                // 간격 추가
                const SizedBox(height: AppSizes.spacingM),

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

                // 충분한 스크롤 공간 확보를 위한 여백
                const SizedBox(height: 50),
              ],
            ),
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
            style: AppTextStyles.heading1.copyWith(
              letterSpacing: 3,
              color: AppColors.primary,
            ),
          ),
          // 타이틀과 시간 표시 사이 간격 추가 (가장 작은 패딩 값 사용)
          // const SizedBox(height: AppSizes.paddingXXS),
          const SizedBox(height: AppSizes.paddingXS),

          // 현재 시간 표시
          const CurrentTimeDisplay(),

          const SizedBox(height: AppSizes.spacingM),

          // 총 펀드 금액 표시
          const TotalFundDisplay(),
        ],
      ),
    );
  }

  // 데이터 로드 메서드
  Future<void> _loadData() async {
    // 마지막 로드 시간으로부터 5초가 지났거나, 첫 로드인 경우에만 데이터 로드
    final now = DateTime.now();
    if (_lastLoadTime == null || now.difference(_lastLoadTime!).inSeconds > 5) {
      _lastLoadTime = now;
      ref.read(projectViewModelProvider.notifier).loadProjects();
    }
  }

  // 새로고침 처리 메서드
  Future<void> _handleRefresh() async {
    _lastLoadTime = DateTime.now();
    await ref.read(projectViewModelProvider.notifier).loadProjects();
  }
}
