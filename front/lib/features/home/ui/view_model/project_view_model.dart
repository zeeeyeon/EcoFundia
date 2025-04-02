import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/home/data/repositories/project_repository_impl.dart';
import 'package:front/features/home/domain/repositories/project_repository.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';
import 'package:logger/logger.dart';

// 프로젝트 상태 정의
class ProjectState {
  final List<ProjectEntity> projects;
  final bool isLoading;
  final String? error;

  ProjectState({
    required this.projects,
    this.isLoading = false,
    this.error,
  });

  ProjectState copyWith({
    List<ProjectEntity>? projects,
    bool? isLoading,
    String? error,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ViewModel 정의
class ProjectViewModel extends StateNotifier<ProjectState> {
  final ProjectRepository _projectRepository;
  final Logger _logger;

  ProjectViewModel(this._projectRepository)
      : _logger = Logger(),
        super(ProjectState(projects: []));

  // 프로젝트 목록 로드
  Future<void> loadProjects() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final projects = await _projectRepository.getProjects();

      // 로딩 상태 설정 후 짧은 지연 - 로딩 인디케이터 표시를 위함
      await Future.delayed(const Duration(milliseconds: 300));

      state = state.copyWith(
        projects: projects,
        isLoading: false,
      );
      _logger.d('프로젝트 로드 완료: ${projects.length}개');
    } catch (e) {
      _logger.e('Error loading projects', error: e);
      state = state.copyWith(
        isLoading: false,
        error: '프로젝트를 불러오는데 실패했습니다.',
      );
    }
  }

  // 좋아요 토글
  Future<void> toggleLike(ProjectEntity project) async {
    // 원본 프로젝트 목록 백업 (실패 시 롤백을 위함)
    final originalProjects = List<ProjectEntity>.from(state.projects);
    final projectIndex = state.projects.indexWhere((p) => p.id == project.id);

    if (projectIndex == -1) return;

    final originalIsLiked = project.isLiked;

    try {
      // 1. Optimistic UI 업데이트 (즉시 UI 반영)
      final updatedProjects = List<ProjectEntity>.from(state.projects);
      updatedProjects[projectIndex] =
          project.copyWith(isLiked: !originalIsLiked);
      state = state.copyWith(projects: updatedProjects);

      _logger.d(
          '🔄 Optimistic UI: Project ${project.id} liked = ${!originalIsLiked}');

      // 2. API 호출 - 현재 isLiked 상태를 전달하여 API에서 중복 확인을 방지
      await _projectRepository.toggleProjectLike(project.id,
          isCurrentlyLiked: originalIsLiked);

      _logger.i('✅ API Success: Wishlist toggled for ${project.id}');
    } catch (e) {
      _logger.e('❌ API Error: Wishlist toggle failed for ${project.id}',
          error: e);

      // 3. 실패 시 UI 롤백
      state = state.copyWith(
        projects: originalProjects,
        error: '찜 상태 변경에 실패했습니다.',
      );
    }
  }
}

// Provider 정의
final projectViewModelProvider =
    StateNotifierProvider<ProjectViewModel, ProjectState>((ref) {
  final projectRepository = ref.watch(projectRepositoryProvider);
  return ProjectViewModel(projectRepository);
});
