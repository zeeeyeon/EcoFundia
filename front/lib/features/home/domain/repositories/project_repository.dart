import 'package:front/features/home/domain/entities/project_entity.dart';

abstract class ProjectRepository {
  Future<List<ProjectEntity>> getProjects();
  Future<void> toggleProjectLike(String projectId);
  Future<ProjectEntity> getProjectById(String projectId);
  Future<int> getTotalFund();
}
