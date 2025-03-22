import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/constants/app_sizes.dart';
import 'package:front/core/constants/loading_state.dart';
import 'package:front/shared/seller/domain/entities/seller_entity.dart';
import 'package:front/shared/seller/domain/entities/seller_project_entity.dart';
import 'package:front/shared/seller/ui/view_model/seller_view_model.dart';
import 'package:front/shared/seller/ui/widgets/seller_info_card.dart';
import 'package:front/shared/seller/ui/widgets/seller_project_card.dart';
import 'package:front/shared/seller/ui/widgets/reviews_tab.dart';
import 'package:front/shared/widgets/error_message_widget.dart';
import 'package:front/shared/widgets/empty_state_widget.dart';
import 'package:go_router/go_router.dart';

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
  void _loadSellerData() {
    final viewModel = ref.read(sellerViewModelProvider);
    viewModel.loadSellerInfo(widget.sellerId);
  }

  /// 탭 변경 처리
  void _handleTabChange() {
    // 필요한 경우 추가 탭 변경 로직 구현
  }

  /// 프로젝트 상세 페이지로 이동
  void _navigateToProjectDetail(SellerProjectEntity project) {
    // 프로젝트 상세 페이지로 이동하는 로직
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('프로젝트: ${project.title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(sellerViewModelProvider);
    final seller = viewModel.seller;

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
            icon: const Icon(Icons.search),
            onPressed: () {
              // 검색 기능 구현
            },
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              // 홈으로 이동
              context.go('/');
            },
          ),
        ],
      ),
      body: viewModel.sellerState == SellerLoadingState.loading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.sellerState == SellerLoadingState.error
              ? ErrorMessageWidget(
                  message: AppStrings.errorLoadingSeller,
                  onRetry: () => _loadSellerData(),
                )
              : seller == null
                  ? const EmptyStateWidget(
                      message: '판매자 정보를 찾을 수 없습니다.',
                      icon: Icons.person_off,
                    )
                  : _buildContent(seller, viewModel),
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
              const EmptyStateWidget(
                message: AppStrings.inquiryInPreparation,
                icon: Icons.chat_bubble_outline,
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
            viewModel.activeProjectsState,
            AppStrings.emptyActiveProjects,
          ),

          const SizedBox(height: AppSizes.spacingL),

          // 종료된 프로젝트 섹션
          Text(AppStrings.endedFunding, style: SellerTextStyles.sectionTitle),
          const SizedBox(height: AppSizes.spacingM),
          _buildProjectSection(
            viewModel.endedProjects,
            viewModel.endedProjectsState,
            AppStrings.emptyEndedProjects,
          ),
        ],
      ),
    );
  }

  /// 프로젝트 섹션 구성
  Widget _buildProjectSection(
    List<SellerProjectEntity> projects,
    SellerLoadingState state,
    String emptyMessage,
  ) {
    return state == SellerLoadingState.loading
        ? const Center(
            child: SizedBox(
              height: 100,
              child: CircularProgressIndicator(),
            ),
          )
        : state == SellerLoadingState.error
            ? ErrorMessageWidget(
                message: AppStrings.errorLoadingProjects,
                onRetry: () => _loadSellerData(),
              )
            : projects.isEmpty
                ? SizedBox(
                    height: 100,
                    child: EmptyStateWidget(
                      message: emptyMessage,
                      icon: Icons.list_alt,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      return SellerProjectCard(
                        project: projects[index],
                        onTap: () => _navigateToProjectDetail(projects[index]),
                      );
                    },
                  );
  }

  /// 리뷰 탭 컨텐츠 구성
  Widget _buildReviewsTab(SellerViewModel viewModel) {
    return viewModel.reviewsState == SellerLoadingState.loading
        ? const Center(child: CircularProgressIndicator())
        : viewModel.reviewsState == SellerLoadingState.error
            ? ErrorMessageWidget(
                message: AppStrings.errorLoadingReviews,
                onRetry: () => _loadSellerData(),
              )
            : viewModel.reviews.isEmpty
                ? const EmptyStateWidget(
                    message: AppStrings.emptyReviews,
                    icon: Icons.rate_review_outlined,
                  )
                : ReviewsTab(
                    reviews: viewModel.reviews,
                    averageRating: viewModel.getAverageRating(),
                    totalReviews: viewModel.reviews.length,
                  );
  }
}
