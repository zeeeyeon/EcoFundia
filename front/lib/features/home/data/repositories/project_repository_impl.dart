import 'package:front/features/home/domain/entities/project_entity.dart';
import 'package:front/features/home/domain/repositories/project_repository.dart';
import 'package:front/features/home/data/services/project_service.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectService _projectService;

  ProjectRepositoryImpl(this._projectService);

  @override
  Future<List<ProjectEntity>> getProjects() async {
    try {
      final projectDTOs = await _projectService.getProjects();
      return projectDTOs.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      // TODO: 에러 처리 구현
      rethrow;
    }
  }

  @override
  Future<void> toggleProjectLike(String projectId) async {
    try {
      await _projectService.toggleProjectLike(projectId);
    } catch (e) {
      // TODO: 에러 처리 구현
      rethrow;
    }
  }

  @override
  Future<ProjectEntity> getProjectById(String projectId) async {
    try {
      final projectDTO = await _projectService.getProjectById(projectId);
      return projectDTO.toEntity();
    } catch (e) {
      // TODO: 에러 처리 구현
      rethrow;
    }
  }
}
