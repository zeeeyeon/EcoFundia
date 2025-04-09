import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/themes/app_shadows.dart';
import 'package:front/features/home/data/repositories/project_repository_impl.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';
import 'package:front/features/home/domain/repositories/project_repository.dart';
import 'package:front/utils/logger_util.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:front/utils/auth_utils.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_provider.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_view_model.dart';
import 'package:front/features/home/ui/view_model/project_view_model.dart';

// ProjectDetail 상태 정의
class ProjectDetailState {
  final ProjectEntity? project;
  final bool isLoading;
  final String? error;

  ProjectDetailState({
    this.project,
    this.isLoading = false,
    this.error,
  });

  ProjectDetailState copyWith({
    ProjectEntity? project,
    bool? isLoading,
    String? error,
  }) {
    return ProjectDetailState(
      project: project ?? this.project,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ProjectDetail ViewModel 정의
class ProjectDetailViewModel extends StateNotifier<ProjectDetailState> {
  final ProjectRepository _repository;
  final int projectId;

  ProjectDetailViewModel(this._repository, this.projectId)
      : super(ProjectDetailState(isLoading: true)) {
    // 생성자에서 데이터 로드 시작
    loadProject();
  }

  // 프로젝트 데이터 로드
  Future<void> loadProject() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final project = await _repository.getProjectById(projectId);
      state = ProjectDetailState(
        project: project,
        isLoading: false,
      );
      LoggerUtil.i('✅ 프로젝트 상세 로드 완료: ${project.id}');
    } catch (e) {
      LoggerUtil.e('❌ 프로젝트 상세 로드 실패', e);
      state = ProjectDetailState(
        isLoading: false,
        error: '프로젝트 상세 정보를 불러오는데 실패했습니다.',
      );
    }
  }

  // 프로젝트 업데이트 (찜하기 등 상태 변경 시)
  void updateProject(ProjectEntity project) {
    if (state.project?.id == project.id) {
      state = state.copyWith(project: project);
      LoggerUtil.d('🔄 프로젝트 상세 상태 업데이트: ${project.id}');
    }
  }
}

// ProjectDetail Provider 정의
final projectDetailProvider = StateNotifierProvider.family<
    ProjectDetailViewModel, ProjectDetailState, int>(
  (ref, projectId) {
    final repository = ref.watch(projectRepositoryProvider);
    return ProjectDetailViewModel(repository, projectId);
  },
);

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final int projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  String _remainingTime = '';
  Timer? _timer;
  ProjectEntity? _currentProject;
  bool _isStoryExpanded = false;
  // Add state variable for chat navigation debouncing
  bool _isNavigatingToChat = false;

  @override
  void initState() {
    super.initState();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemainingTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateRemainingTime() {
    if (_currentProject == null) return;

    final now = DateTime.now();
    final endDate = _currentProject!.endDate;

    if (endDate.isBefore(now)) {
      setState(() {
        _remainingTime = '마감됨';
      });
      return;
    }

    final duration = endDate.difference(now);
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    setState(() {
      if (days > 0) {
        _remainingTime =
            '$days일 ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} 남음';
      } else {
        _remainingTime =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} 남음';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // 프로젝트 상세 정보 가져오기
    final projectDetailState =
        ref.watch(projectDetailProvider(widget.projectId));

    // 로딩 중 상태 확인
    if (projectDetailState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('프로젝트 상세'),
          backgroundColor: AppColors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 에러 상태 확인
    if (projectDetailState.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('프로젝트 상세'),
          backgroundColor: AppColors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.grey),
              const SizedBox(height: 16),
              Text(
                projectDetailState.error!,
                style: AppTextStyles.body1,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // 프로바이더 새로고침
                  ref
                      .read(projectDetailProvider(widget.projectId).notifier)
                      .loadProject();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    // 데이터가 없는 경우 확인
    if (projectDetailState.project == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('프로젝트 상세'),
          backgroundColor: AppColors.white,
        ),
        body: const Center(
          child: Text('프로젝트 정보를 찾을 수 없습니다.'),
        ),
      );
    }

    // 프로젝트 데이터 사용
    final project = projectDetailState.project!;
    _currentProject = project;
    _calculateRemainingTime();

    // 타이머가 실행 중이 아니면 시작
    if (_timer == null || !_timer!.isActive) {
      _startTimer();
    }

    // wishlistIdsProvider 구독 추가
    final Set<int> wishlistIds = ref.watch(wishlistIdsProvider);
    // isLiked 상태 계산
    final bool isLiked = wishlistIds.contains(project.id);

    return _buildContent(context, screenSize, project);
  }

  // 프로젝트 상세 화면 UI 빌드
  Widget _buildContent(
      BuildContext context, Size screenSize, ProjectEntity project) {
    // wishlistIdsProvider 구독 추가
    final Set<int> wishlistIds = ref.watch(wishlistIdsProvider);
    // isLiked 상태 계산
    final bool isLiked = wishlistIds.contains(project.id);

    return Scaffold(
      backgroundColor: AppColors.white,
      persistentFooterButtons: [
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ElevatedButton(
            onPressed: () async {
              final isLoggedIn = ref.read(isLoggedInProvider);
              if (!isLoggedIn) {
                LoggerUtil.d('💰 하단 펀딩하기 버튼: 로그인 필요');
              }
              final isAuthenticated = await AuthUtils.checkAuthAndShowModal(
                context,
                ref,
              );
              if (!isAuthenticated) {
                LoggerUtil.d('💰 하단 펀딩하기 버튼: 인증 필요 → 모달 표시됨');
                return;
              }
              LoggerUtil.d('💰 하단 펀딩하기 버튼: 인증 성공 → 펀딩 페이지 이동');
              if (context.mounted) {
                context.push('/payment/${project.id}', extra: project);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('펀딩 페이지로 이동합니다.'),
                      duration: Duration(seconds: 2)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: const Text(
              '펀딩하기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: screenSize.height * 0.4,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.darkGrey,
                    size: 20,
                  ),
                ),
                onPressed: () => context.pop(),
              ),
              actions: [
                // 찜하기 버튼
                IconButton(
                  icon: Icon(
                    // isLiked 상태에 따라 아이콘 변경
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    // isLiked 상태에 따라 색상 변경
                    color: isLiked ? AppColors.primary : AppColors.grey,
                  ),
                  onPressed: () async {
                    LoggerUtil.d('❤️ 상세 페이지 찜하기 버튼 클릭: ${project.id}');
                    // 로그인 확인
                    final isAuthorized = await AuthUtils.checkAuthAndShowModal(
                      context,
                      ref,
                    );
                    if (isAuthorized && context.mounted) {
                      // WishlistViewModel의 토글 메서드 호출
                      await ref
                          .read(wishlistViewModelProvider.notifier)
                          .toggleWishlistItem(project.id, context: context);
                      // 토글 후 상세 정보 갱신은 ProjectViewModel의 역할이 아님
                      // ProjectViewModel의 리스너가 wishlistIdsProvider 변경을 감지하여
                      // 프로젝트 리스트의 isLiked 상태를 업데이트하므로, 여기서 별도 갱신 불필요
                      // 화면 자체의 isLiked 상태는 ref.watch에 의해 자동으로 갱신됨
                    }
                  },
                  tooltip: '찜하기',
                ),
                // 공유 버튼 (기존 코드 유지)
                IconButton(
                  icon: const Icon(Icons.share, color: AppColors.grey),
                  onPressed: () {
                    // TODO: 공유 기능 구현
                    LoggerUtil.d('🔗 공유 버튼 클릭');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('공유 기능은 준비 중입니다.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  tooltip: '공유하기',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: project.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.lightGrey.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.lightGrey.withOpacity(0.3),
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: AppColors.grey,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 그래디언트 오버레이
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                            stops: const [0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // 제목
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Text(
                        project.title,
                        style: AppTextStyles.heading3.copyWith(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 8.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [AppShadows.card],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${project.percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '남은시간: $_remainingTime',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 프로그레스 바
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // 펀딩률(0.0 ~ 1.0)을 계산하고 0과 1 사이로 제한(clamp)합니다.
                          // 이렇게 하면 100%를 초과해도 시각적으로는 100%까지만 표시됩니다.
                          final clampedPercentage =
                              (project.percentage / 100).clamp(0.0, 1.0);
                          final width =
                              constraints.maxWidth * clampedPercentage;
                          return Row(
                            children: [
                              Container(
                                width: width,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      Color(0xFF8BC34A),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 펀딩 금액 및 버튼 -> 펀딩 금액 오른쪽 정렬
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          // 가로 배치를 위해 Row 추가
                          children: [
                            Text(
                              '펀딩 금액', // 레이블
                              style: AppTextStyles.body1.copyWith(
                                color: AppColors.darkGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8), // 레이블과 금액 사이 간격
                            Text(
                              project.price, // 금액
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 22, // 금액 폰트 크기 조정 가능
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 판매자 정보 박스
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: _buildSellerInfoBox(context, project),
              ),
            ),

            // Project Introduction section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [AppShadows.card],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '프로젝트 소개',
                          style: AppTextStyles.heading3.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 고정된 프로젝트 소개 문구 제거

                    // 스토리 이미지 표시 부분 - 로깅 추가
                    if (project.storyFileUrl != null &&
                        project.storyFileUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '스토리 이미지',
                                  style: AppTextStyles.body1.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            // Debug URL removed
                            const SizedBox(
                                height:
                                    8), // Adjusted spacing after removing debug URL
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Column(
                                children: [
                                  // 이미지 컨테이너 - 확장 상태에 따라 다르게 표시
                                  Container(
                                    constraints: BoxConstraints(
                                      maxHeight: _isStoryExpanded
                                          ? double.infinity
                                          : 300,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: CachedNetworkImage(
                                      imageUrl: project.storyFileUrl!,
                                      imageBuilder: (context, imageProvider) =>
                                          Image(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                        filterQuality: FilterQuality.high,
                                        width: double.infinity,
                                      ),
                                      alignment: Alignment.topCenter,
                                      fadeInDuration:
                                          const Duration(milliseconds: 300),
                                      httpHeaders: const {
                                        'Accept':
                                            'image/webp,image/*,*/*;q=0.8',
                                      },
                                      placeholder: (context, url) {
                                        LoggerUtil.d('스토리 이미지 로딩 중: $url');
                                        return Container(
                                          height: 200,
                                          color: AppColors.lightGrey
                                              .withOpacity(0.3),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                '이미지 로딩 중...',
                                                style: AppTextStyles.body2
                                                    .copyWith(
                                                  color: AppColors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                url,
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                  color: AppColors.grey,
                                                  fontSize: 10,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      errorWidget: (context, url, error) {
                                        // 에러 위젯 - 더 자세한 정보 제공
                                        LoggerUtil.e(
                                            '스토리 이미지 로드 실패: $url', error);
                                        LoggerUtil.e(
                                            '스토리 이미지 오류 세부 정보: ${error.toString()}');
                                        final errorString =
                                            error.toString().toLowerCase();
                                        // WebGL 텍스처 크기 제한 또는 기타 렌더링 관련 오류 감지
                                        final isWebGLError = errorString
                                                .contains('webgl') ||
                                            errorString.contains('texture') ||
                                            errorString.contains('range');

                                        // 참고: 이미지 로드 실패의 근본 원인이 URL 자체(잘못된 주소, 서버 문제, CORS 등)일 수도 있습니다.
                                        // URL이 올바른지 확인하는 것이 중요합니다.
                                        return Container(
                                          height: 200,
                                          color: AppColors.lightGrey
                                              .withOpacity(0.3),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.error_outline,
                                                color: AppColors.grey,
                                                size: 40,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                isWebGLError
                                                    ? '이미지가 너무 큽니다. 개발자에게 문의하세요.'
                                                    : '이미지를 불러올 수 없습니다.',
                                                textAlign: TextAlign.center,
                                                style: AppTextStyles.body2
                                                    .copyWith(
                                                  color: AppColors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              GestureDetector(
                                                onTap: () {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content:
                                                          Text('이미지 URL: $url'),
                                                      duration: const Duration(
                                                          seconds: 5),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.grey
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: const Text(
                                                    '이미지 URL 보기',
                                                    style: TextStyle(
                                                      color: AppColors.darkGrey,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 8.0),
                                                child: Text(
                                                  '이미지 파일 문제가 발생했습니다.',
                                                  textAlign: TextAlign.center,
                                                  style: AppTextStyles.caption
                                                      .copyWith(
                                                    color: AppColors.grey,
                                                    fontSize: 10,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // 더보기/접기 버튼
                                  if (!_isStoryExpanded) // 확장되지 않았을 때만 더보기 버튼 표시
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _isStoryExpanded = true;
                                        });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '이미지 더보기',
                                              style:
                                                  AppTextStyles.body2.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // 확장된 상태에서 하단 버튼 표시 (기능: 이미지 접기)
                            if (_isStoryExpanded)
                              Container(
                                margin: const EdgeInsets.only(top: 16),
                                child: Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _isStoryExpanded = false; // 이미지 접기
                                      });
                                    },
                                    icon: const Icon(
                                        Icons
                                            .arrow_upward, // 아이콘은 유지하거나 변경 고려 (e.g., Icons.unfold_less)
                                        size: 16),
                                    label: const Text('접기'), // 버튼 텍스트를 '접기'로 변경
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                    // 추가 정보
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '펀딩 참여 혜택',
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBenefitItem('프로젝트 완성품을 가장 먼저 받아보실 수 있습니다.'),
                          _buildBenefitItem('제작 과정에 참여할 수 있는 기회가 주어집니다.'),
                          _buildBenefitItem('참여자 이름이 프로젝트 공식 웹사이트에 기재됩니다.'),
                          _buildBenefitItem('프로젝트 관련 이벤트에 우선 초대됩니다.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerInfoBox(BuildContext context, ProjectEntity project) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '판매자 정보',
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 판매자 프로필 이미지
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: project.sellerImageUrl != null &&
                        project.sellerImageUrl!.isNotEmpty
                    ? NetworkImage(project.sellerImageUrl!) as ImageProvider
                    : const AssetImage('assets/images/apple.png'),
                child: project.sellerImageUrl == null ||
                        project.sellerImageUrl!.isEmpty
                    ? const Icon(
                        Icons.store,
                        size: 30,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // 판매자 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 판매자 이름 + 아이콘 Row로 감싸고 InkWell 추가
                    InkWell(
                      onTap: () {
                        // 판매자 상세 페이지로 이동
                        context.push('/seller/${project.sellerId}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${project.sellerName ?? '판매자'} 페이지로 이동합니다.'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Row 크기를 내용에 맞춤
                        children: [
                          Flexible(
                            child: Text(
                              project.sellerName ?? '판매자 정보 없음',
                              style: AppTextStyles.heading4.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis, // 이름 길 경우 대비
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 채팅하기 버튼
              Align(
                alignment: Alignment.topRight,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Debouncing check
                    if (_isNavigatingToChat) {
                      LoggerUtil.w('채팅방 이동 중복 호출 방지됨');
                      return;
                    }

                    _isNavigatingToChat = true;
                    LoggerUtil.d('채팅방 이동 시작: fundingId=${project.id}');

                    try {
                      // Check authentication
                      final isLoggedIn = ref.read(isLoggedInProvider);
                      if (!isLoggedIn) {
                        LoggerUtil.d('💬 채팅방 참여 버튼: 로그인 필요');
                      }
                      final isAuthenticated =
                          await AuthUtils.checkAuthAndShowModal(
                        context,
                        ref,
                      );
                      if (!isAuthenticated) {
                        LoggerUtil.d('💬 채팅방 참여 버튼: 인증 필요 → 모달 표시됨');
                        return; // Exit if not authenticated
                      }

                      LoggerUtil.d('💬 채팅방 참여 버튼: 인증 성공 → 채팅방 이동');

                      // Navigate to chat room
                      // Ensure context is still mounted before navigation
                      if (!context.mounted) return;
                      // Revert back to context.push
                      await context.push(
                        '/chat/room/${project.id}',
                        extra: {'title': project.title},
                      );
                      LoggerUtil.d('채팅방 이동 호출 완료');
                    } catch (e, s) {
                      // Use correct parameter names for LoggerUtil.e
                      LoggerUtil.e('채팅방 이동 중 오류', e, s);
                      // Optionally show an error message to the user
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('채팅방 이동 중 오류가 발생했습니다: $e')),
                        );
                      }
                    } finally {
                      // Reset the flag after a delay
                      Future.delayed(const Duration(milliseconds: 500), () {
                        // Check if the state is still mounted before modifying state variable
                        if (mounted) {
                          _isNavigatingToChat = false;
                        }
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    '채팅하기',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body2,
            ),
          ),
        ],
      ),
    );
  }
}
