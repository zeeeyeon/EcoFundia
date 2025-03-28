import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/features/home/data/services/project_api_service.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';
import 'package:front/features/home/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectService _projectService;

  ProjectRepositoryImpl(this._projectService);

  @override
  Future<List<ProjectEntity>> getProjects() async {
    final dtos = await _projectService.getProjects();
    return dtos.map((dto) => ProjectEntity.fromDTO(dto)).toList();
  }

  @override
  Future<void> toggleProjectLike(String projectId) async {
    await _projectService.toggleProjectLike(projectId);
  }

  @override
  Future<ProjectEntity> getProjectById(String projectId) async {
    final dto = await _projectService.getProjectById(projectId);
    return ProjectEntity.fromDTO(dto);
  }

  @override
  Future<int> getTotalFund() async {
    return await _projectService.getTotalFund();
  }
}

final projectServiceProvider = Provider<ProjectService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ProjectApiService(apiService.dio);
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final projectService = ref.watch(projectServiceProvider);
  return ProjectRepositoryImpl(projectService);
});
