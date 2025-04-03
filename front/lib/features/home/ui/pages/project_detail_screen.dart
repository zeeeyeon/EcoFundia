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
import 'package:url_launcher/url_launcher.dart';

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

    return _buildContent(context, screenSize, project);
  }

  // 프로젝트 상세 화면 UI 빌드
  Widget _buildContent(
      BuildContext context, Size screenSize, ProjectEntity project) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
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
                      child: Icon(
                        project.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            project.isLiked ? Colors.red : AppColors.darkGrey,
                        size: 20,
                      ),
                    ),
                    onPressed: () async {
                      // 동기 Provider를 통해 로그인 상태 확인 (즉각적인 상태 확인)
                      final isLoggedIn = ref.read(isLoggedInProvider);

                      if (!isLoggedIn) {
                        LoggerUtil.d('❤️ 좋아요 버튼 클릭: 로그인 필요 (동기 상태 체크)');
                      }

                      // 로그인 상태 체크 및 모달 표시
                      final isAuthenticated =
                          await AuthUtils.checkAuthAndShowModal(
                        context,
                        ref,
                        AuthRequiredFeature.like,
                      );

                      if (!isAuthenticated) {
                        LoggerUtil.d('❤️ 좋아요 버튼: 인증 필요 → 로그인 모달 표시됨');
                        return; // 인증되지 않으면 좋아요 기능 실행하지 않음
                      }

                      // 토큰 유효성 추가 검증 (로그인된 상태에서만 필요)
                      if (isAuthenticated) {
                        // 실제 토큰이 유효한지 스토리지에서 다시 확인
                        final hasValidToken =
                            await ref.read(isAuthenticatedProvider.future);
                        if (!hasValidToken) {
                          LoggerUtil.d('❤️ 좋아요 버튼: 토큰 만료됨, 재인증 필요');
                          return; // 토큰이 유효하지 않으면 작업 중단
                        }
                      }

                      LoggerUtil.d('❤️ 좋아요 버튼: 인증 성공 → 좋아요 기능 실행');

                      // 현재 상태 저장
                      final isCurrentlyLiked = project.isLiked;

                      // 1. Optimistic UI 업데이트 (즉시 UI 반영)
                      // 프로젝트 상태를 낙관적으로 업데이트
                      final updatedProject =
                          project.copyWith(isLiked: !isCurrentlyLiked);
                      ref
                          .read(
                              projectDetailProvider(widget.projectId).notifier)
                          .updateProject(updatedProject);

                      // 스낵바 표시
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isCurrentlyLiked
                                ? '찜 목록에서 제거되었습니다.'
                                : '찜 목록에 추가되었습니다.',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );

                      // 2. API 호출 - 현재 isLiked 상태를 전달하여 API에서 중복 확인을 방지
                      ref
                          .read(projectRepositoryProvider)
                          .toggleProjectLike(
                            project.id,
                            isCurrentlyLiked: isCurrentlyLiked,
                          )
                          .catchError((error) {
                        LoggerUtil.e('찜하기 토글 실패', error);

                        // 3. 실패 시 UI 롤백
                        ref
                            .read(projectDetailProvider(widget.projectId)
                                .notifier)
                            .updateProject(project);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('찜하기 처리 중 오류가 발생했습니다.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      });
                    },
                  ),
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
                          final width =
                              constraints.maxWidth * (project.percentage / 100);
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
                    // 펀딩 금액 및 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '펀딩 금액',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              project.price,
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            // 로그인 상태 체크
                            // 동기 Provider로 로그인 상태 먼저 확인
                            final isLoggedIn = ref.read(isLoggedInProvider);

                            if (!isLoggedIn) {
                              LoggerUtil.d('💰 펀딩하기 버튼: 로그인 필요 (동기 상태 체크)');
                            }

                            // 로그인 모달 표시 로직 (필요시)
                            final isAuthenticated =
                                await AuthUtils.checkAuthAndShowModal(
                              context,
                              ref,
                              AuthRequiredFeature.funding,
                            );

                            if (!isAuthenticated) {
                              LoggerUtil.d('💰 펀딩하기 버튼: 인증 필요 → 로그인 모달 표시됨');
                              return; // 인증되지 않으면 펀딩 기능 실행하지 않음
                            }

                            // 인증된 경우 펀딩 로직 실행
                            LoggerUtil.d('💰 펀딩하기 버튼: 인증 성공 → 펀딩 페이지로 이동');

                            // 펀딩 페이지로 이동
                            context.go('/payment/${project.id}');

                            // 스낵바로 안내
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('펀딩 페이지로 이동합니다.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            '펀딩하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                    Text(
                      '이 프로젝트는 ${project.title}로, 혁신적인 아이디어와 기술을 통해 사용자들에게 새로운 가치를 제공합니다. 저희 팀은 열정과 전문성을 바탕으로 이 프로젝트를 성공적으로 완수하기 위해 최선을 다하고 있습니다.\n\n여러분의 지원과 관심이 이 프로젝트의 성공에 큰 힘이 됩니다. 함께해 주셔서 감사합니다!',
                      style: AppTextStyles.body1,
                    ),

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
                                if (_isStoryExpanded)
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _isStoryExpanded = false;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.arrow_upward,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    label: Text(
                                      '처음으로',
                                      style: AppTextStyles.body2.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            // URL 디버깅 표시
                            Text(
                              '디버그 URL: ${project.storyFileUrl}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.grey,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 10),
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
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                      memCacheWidth: 1024,
                                      memCacheHeight: 2048,
                                      fadeInDuration:
                                          const Duration(milliseconds: 300),
                                      maxWidthDiskCache: 1024,
                                      maxHeightDiskCache: 2048,
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
                                        final isWebGLError = errorString
                                                .contains('webgl') ||
                                            errorString.contains('texture') ||
                                            errorString.contains('range');

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

                            // 확장된 상태에서 스크롤 위치가 내려가면 상단으로 이동 버튼 표시 (처음으로 버튼 대체)
                            if (_isStoryExpanded)
                              Container(
                                margin: const EdgeInsets.only(top: 16),
                                child: Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _isStoryExpanded = false;
                                      });
                                    },
                                    icon: const Icon(Icons.arrow_upward,
                                        size: 16),
                                    label: const Text('처음으로'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(
                      project.sellerName ?? '판매자 정보 없음',
                      style: AppTextStyles.heading4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (project.sellerDescription != null &&
                        project.sellerDescription!.isNotEmpty)
                      Text(
                        project.sellerDescription!,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.darkGrey,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          project.location ?? '위치 정보 없음',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 판매자 문의 버튼
              ElevatedButton.icon(
                onPressed: () {
                  // 판매자 문의 기능
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('판매자 문의 기능은 준비 중입니다.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.message_outlined,
                  size: 18,
                ),
                label: const Text('문의하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  side: const BorderSide(
                    color: AppColors.primary,
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: OutlinedButton(
              onPressed: () {
                // 판매자 상세 페이지로 이동
                context.push('/seller/${project.sellerId}');

                // 스낵바로 이동 알림
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${project.sellerName} 판매자 페이지로 이동합니다.'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.grey,
                side: const BorderSide(color: AppColors.lightGrey),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text('판매자 정보 더보기'),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                  ),
                ],
              ),
            ),
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
