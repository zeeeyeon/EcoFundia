import 'package:front/features/home/domain/entities/project_entity.dart';

abstract class ProjectRepository {
  Future<List<ProjectEntity>> getProjects();
  Future<void> toggleProjectLike(int projectId, {bool? isCurrentlyLiked});
  Future<ProjectEntity> getProjectById(int projectId);
  Future<int> getTotalFund();
}
