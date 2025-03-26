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
      state = state.copyWith(
        projects: projects,
        isLoading: false,
      );
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
    try {
      await _projectRepository.toggleProjectLike(project.id);
      final updatedProjects = state.projects.map((p) {
        if (p.id == project.id) {
          return p.copyWith(isLiked: !p.isLiked);
        }
        return p;
      }).toList();

      state = state.copyWith(projects: updatedProjects);
    } catch (e) {
      _logger.e('Error toggling project like', error: e);
      // TODO: Show error message to user
    }
  }
}

// Provider 정의
final projectViewModelProvider =
    StateNotifierProvider<ProjectViewModel, ProjectState>((ref) {
  final projectRepository = ref.watch(projectRepositoryProvider);
  return ProjectViewModel(projectRepository);
});
