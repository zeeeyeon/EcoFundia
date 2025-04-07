import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/constants/app_sizes.dart';
import 'package:front/core/constants/loading_state.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/shared/seller/domain/entities/seller_entity.dart';
import 'package:front/shared/seller/domain/entities/seller_project_entity.dart';
import 'package:front/shared/seller/ui/view_model/seller_view_model.dart';
import 'package:front/shared/seller/ui/widgets/seller_info_card.dart';
import 'package:front/shared/seller/ui/widgets/seller_project_card.dart';
import 'package:front/shared/seller/ui/widgets/reviews_tab.dart';
import 'package:front/shared/widgets/error_message_widget.dart';
import 'package:front/shared/widgets/empty_state_widget.dart';
import 'package:front/utils/logger_util.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// 판매자 상세 화면
class SellerDetailScreen extends ConsumerStatefulWidget {
  final int sellerId;

  const SellerDetailScreen({
    super.key,
    required this.sellerId,
  });

  @override
  ConsumerState<SellerDetailScreen> createState() => _SellerDetailScreenState();
}

class _SellerDetailScreenState extends ConsumerState<SellerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isRetrying = false; // 자동 재시도 중인지 여부
  int _retryCount = 0; // 재시도 횟수

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3개 탭으로 변경
    _tabController.addListener(_handleTabChange);

    // 판매자 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSellerData();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  /// 판매자 데이터 로드
  Future<void> _loadSellerData() async {
    final viewModel = ref.read(sellerViewModelProvider);
    await viewModel.loadSellerInfo(widget.sellerId);

    // 로드 후 상태 확인하여 필요시 재시도
    final sellerState = _convertLoadingState(viewModel.sellerState);

    // 네트워크 오류일 경우 자동으로 한 번 더 시도
    if (sellerState == LoadingState.networkError &&
        !_isRetrying &&
        _retryCount < 1) {
      _isRetrying = true;
      _retryCount++;

      if (kDebugMode) {
        LoggerUtil.i('🔄 네트워크 오류 감지, 자동 재시도 ($_retryCount/1)');
      }

      // 약간의 지연 후 재시도
      Future.delayed(const Duration(milliseconds: 1500), () async {
        // 위젯이 아직 마운트되어 있는지 확인
        if (!mounted) return;

        // 네트워크 연결 테스트
        final apiService = ref.read(apiServiceProvider);
        final isConnected = await apiService.testConnection();

        if (isConnected) {
          if (kDebugMode) {
            LoggerUtil.i('✅ 네트워크 연결 복구 확인, 데이터 다시 로드');
          }
          if (mounted) {
            await viewModel.loadSellerInfo(widget.sellerId);
          }
        } else {
          if (kDebugMode) {
            LoggerUtil.w('⚠️ 네트워크 연결 복구 실패');
          }
        }

        if (mounted) {
          setState(() {
            _isRetrying = false;
          });
        }
      });
    }
  }

  /// 판매자 데이터 수동 새로고침
  Future<void> _refreshSellerData() async {
    // 재시도 카운트 초기화
    _retryCount = 0;
    _isRetrying = false;

    final viewModel = ref.read(sellerViewModelProvider);
    await viewModel.refreshAllData(widget.sellerId);
  }

  /// 탭 변경 처리
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      return;
    }

    final viewModel = ref.read(sellerViewModelProvider);
    final sellerId = widget.sellerId;

    // 선택된 탭 인덱스에 따라 처리
    switch (_tabController.index) {
      case 0: // 프로젝트 탭
        // 이미 판매자 정보 로딩 시 함께 로드되므로 추가 작업 필요 없음
        // 단, 오류 상태인 경우 다시 로드
        if (viewModel.activeProjectsState == SellerLoadingState.error ||
            viewModel.activeProjectsState == SellerLoadingState.networkError ||
            viewModel.endedProjectsState == SellerLoadingState.error ||
            viewModel.endedProjectsState == SellerLoadingState.networkError) {
          if (kDebugMode) {
            LoggerUtil.i('🔄 프로젝트 탭 선택 - 프로젝트 데이터 재로드 시작');
          }
          viewModel.refreshProjects(sellerId);
        }
        break;
      case 1: // 리뷰 탭
        // 리뷰가 로드되지 않았거나 오류 상태인 경우 리뷰 데이터 로드
        if (viewModel.reviewsState == SellerLoadingState.initial ||
            viewModel.reviewsState == SellerLoadingState.error ||
            viewModel.reviewsState == SellerLoadingState.networkError) {
          if (kDebugMode) {
            LoggerUtil.i('🔄 리뷰 탭 선택 - 리뷰 데이터 로드 시작');
          }
          viewModel.loadReviews(sellerId);
        }
        break;
      case 2: // 문의하기 탭
        // 필요 시 문의 데이터 로드 로직 추가 (현재는 준비 중 메시지 표시)
        if (kDebugMode) {
          LoggerUtil.i('🔄 문의하기 탭 선택');
        }
        break;
    }
  }

  /// 프로젝트 상세 페이지로 이동
  void _navigateToProjectDetail(SellerProjectEntity project) {
    if (kDebugMode) {
      LoggerUtil.i(
          '🚀 프로젝트 상세 페이지로 이동: ID ${project.id}, 제목: ${project.title}');
    }
    // 프로젝트 상세 페이지로 이동 (push 사용으로 변경)
    context.push('/project/${project.id}');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(sellerViewModelProvider);
    final seller = viewModel.seller;
    final isLoading = viewModel.isLoading;

    // SellerLoadingState를 LoadingState로 변환
    final sellerState = _convertLoadingState(viewModel.sellerState);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(seller?.name ?? '판매자 정보'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSellerData,
            tooltip: '새로고침',
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshSellerData,
        child: Stack(
          children: [
            // 메인 콘텐츠
            _buildMainContent(sellerState, viewModel, seller),

            // 로딩 인디케이터 (데이터 리프레시 중일 때 상단에 표시)
            if (isLoading && sellerState != LoadingState.loading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                ),
              ),

            // 자동 재시도 중인 경우 표시
            if (_isRetrying && sellerState == LoadingState.networkError)
              _buildNetworkRetryIndicator(),
          ],
        ),
      ),
    );
  }

  /// 메인 콘텐츠 구성 (로딩/오류/콘텐츠 상태 관리)
  Widget _buildMainContent(LoadingState sellerState, SellerViewModel viewModel,
      SellerEntity? seller) {
    if (sellerState == LoadingState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sellerState == LoadingState.error) {
      return ErrorMessageWidget(
        message: AppStrings.errorLoadingSeller,
        onRetry: () => _loadSellerData(),
        isNetworkError: false,
      );
    }

    if (sellerState == LoadingState.networkError) {
      return ErrorMessageWidget(
        message: _isRetrying
            ? '네트워크 연결 복구 중입니다. 잠시만 기다려 주세요...'
            : viewModel.errorMessage,
        onRetry: () => _refreshSellerData(),
        isNetworkError: true,
      );
    }

    if (seller == null) {
      return const EmptyStateWidget(
        message: '판매자 정보를 찾을 수 없습니다.',
        icon: Icons.person_off,
      );
    }

    return _buildContent(seller, viewModel);
  }

  /// 네트워크 재시도 중 표시 위젯
  Widget _buildNetworkRetryIndicator() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '네트워크 재연결 중...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 화면 콘텐츠 구성
  Widget _buildContent(SellerEntity seller, SellerViewModel viewModel) {
    return Column(
      children: [
        // 판매자 정보 카드
        Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: SellerInfoCard(seller: seller),
        ),

        // 탭바 (프로젝트, 리뷰, 문의하기)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: SellerTextStyles.tabSelected,
            unselectedLabelStyle: SellerTextStyles.tabUnselected,
            tabs: const [
              Tab(text: AppStrings.tabProjects),
              Tab(text: AppStrings.tabReviews),
              Tab(text: AppStrings.tabInquiry),
            ],
          ),
        ),

        // 탭 컨텐츠
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 1. 프로젝트 탭 (진행 중 + 종료된)
              _buildProjectsTab(viewModel),

              // 2. 리뷰 탭
              _buildReviewsTab(viewModel),

              // 3. 문의하기 탭
              _buildEmptyContainer(
                message: AppStrings.inquiryInPreparation,
                icon: Icons.chat_bubble_outline,
                height: double.infinity,
                margin: const EdgeInsets.all(AppSizes.paddingM),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 프로젝트 탭 컨텐츠 구성
  Widget _buildProjectsTab(SellerViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 진행 중인 프로젝트 섹션
          Text(AppStrings.activeFunding, style: SellerTextStyles.sectionTitle),
          const SizedBox(height: AppSizes.spacingM),
          _buildProjectSection(
            viewModel.activeProjects,
            _convertLoadingState(viewModel.activeProjectsState),
            AppStrings.emptyActiveProjects,
            viewModel.isNetworkError,
            viewModel.errorMessage,
            viewModel.seller,
          ),

          const SizedBox(height: AppSizes.spacingL),

          // 종료된 프로젝트 섹션
          Text(AppStrings.endedFunding, style: SellerTextStyles.sectionTitle),
          const SizedBox(height: AppSizes.spacingM),
          _buildProjectSection(
            viewModel.endedProjects,
            _convertLoadingState(viewModel.endedProjectsState),
            AppStrings.emptyEndedProjects,
            viewModel.isNetworkError,
            viewModel.errorMessage,
            viewModel.seller,
          ),

          // 여백 추가
          const SizedBox(height: AppSizes.spacingL),
        ],
      ),
    );
  }

  /// 빈 상태를 표시하는 공통 컨테이너
  Widget _buildEmptyContainer({
    required String message,
    required IconData icon,
    double height = 150,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      height: height,
      alignment: Alignment.center,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40.0,
            color: AppColors.grey.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.emptyMessage.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 프로젝트 섹션 구성
  Widget _buildProjectSection(
    List<SellerProjectEntity> projects,
    LoadingState state,
    String emptyMessage,
    bool isNetworkError,
    String errorMessage,
    SellerEntity? seller,
  ) {
    if (state == LoadingState.loading) {
      return const Center(
        child: SizedBox(
          height: 100,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state == LoadingState.error || state == LoadingState.networkError) {
      return ErrorMessageWidget(
        message: state == LoadingState.networkError
            ? errorMessage
            : AppStrings.errorLoadingProjects,
        onRetry: () => _refreshSellerData(),
        isNetworkError: isNetworkError,
      );
    }

    if (projects.isEmpty || seller == null) {
      return _buildEmptyContainer(
        message: seller == null ? '판매자 정보를 불러올 수 없습니다.' : emptyMessage,
        icon: Icons.list_alt,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return SellerProjectCard(
          seller: seller,
          project: projects[index],
          onTap: () => _navigateToProjectDetail(projects[index]),
        );
      },
    );
  }

  /// 리뷰 탭 컨텐츠 구성
  Widget _buildReviewsTab(SellerViewModel viewModel) {
    final reviewsState = _convertLoadingState(viewModel.reviewsState);

    if (reviewsState == LoadingState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reviewsState == LoadingState.error ||
        reviewsState == LoadingState.networkError) {
      return ErrorMessageWidget(
        message: reviewsState == LoadingState.networkError
            ? viewModel.errorMessage
            : AppStrings.errorLoadingReviews,
        onRetry: () => _refreshSellerData(),
        isNetworkError: viewModel.isNetworkError,
      );
    }

    if (viewModel.reviews.isEmpty) {
      return _buildEmptyContainer(
        message: AppStrings.emptyReviews,
        icon: Icons.rate_review_outlined,
        height: 200,
        margin: const EdgeInsets.all(AppSizes.paddingM),
      );
    }

    return ReviewsTab(
      reviews: viewModel.reviews,
      averageRating: viewModel.getAverageRating(),
      totalReviews: viewModel.reviews.length,
    );
  }

  /// SellerLoadingState를 LoadingState로 변환
  LoadingState _convertLoadingState(SellerLoadingState state) {
    switch (state) {
      case SellerLoadingState.initial:
        return LoadingState.initial;
      case SellerLoadingState.loading:
        return LoadingState.loading;
      case SellerLoadingState.loaded:
        return LoadingState.loaded;
      case SellerLoadingState.error:
        return LoadingState.error;
      case SellerLoadingState.networkError:
        return LoadingState.networkError;
      default:
        return LoadingState.initial;
    }
  }
}
