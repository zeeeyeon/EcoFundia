import 'package:dio/dio.dart';
import 'package:front/features/home/data/models/project_dto.dart';
import 'package:front/shared/dummy/data/project_dummy.dart';
import 'package:logger/logger.dart';

abstract class ProjectService {
  Future<List<ProjectDTO>> getProjects();
  Future<void> toggleProjectLike(String projectId);
  Future<ProjectDTO> getProjectById(String projectId);
  Future<int> getTotalFund();
}

class ProjectApiService extends ProjectService {
  final Dio _dio;
  final Logger _logger;
  int _currentFundIndex = 0;

  ProjectApiService(this._dio) : _logger = Logger();

  @override
  Future<List<ProjectDTO>> getProjects() async {
    try {
      _logger.d('Fetching projects from API');
      await Future.delayed(
          const Duration(milliseconds: 500)); // 실제 API 호출처럼 보이게 하기 위한 지연
      return projectDummyList;
    } catch (e) {
      _logger.e('Error fetching projects', error: e);
      rethrow;
    }
  }

  @override
  Future<void> toggleProjectLike(String projectId) async {
    try {
      _logger.d('Toggling like for project: $projectId');
      await Future.delayed(const Duration(milliseconds: 300));
      final index = projectDummyList.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        projectDummyList[index] = ProjectDTO(
          id: projectDummyList[index].id,
          title: projectDummyList[index].title,
          description: projectDummyList[index].description,
          imageUrl: projectDummyList[index].imageUrl,
          percentage: projectDummyList[index].percentage,
          price: projectDummyList[index].price,
          remainingTime: projectDummyList[index].remainingTime,
          isLiked: !projectDummyList[index].isLiked,
        );
      }
    } catch (e) {
      _logger.e('Error toggling project like', error: e);
      rethrow;
    }
  }

  @override
  Future<ProjectDTO> getProjectById(String projectId) async {
    try {
      _logger.d('Fetching project details: $projectId');
      await Future.delayed(const Duration(milliseconds: 500));
      final project = projectDummyList.firstWhere(
        (p) => p.id == projectId,
        orElse: () => throw Exception('Project not found'),
      );
      return project;
    } catch (e) {
      _logger.e('Error fetching project details', error: e);
      rethrow;
    }
  }

  @override
  Future<int> getTotalFund() async {
    try {
      _logger.d('Fetching total fund');
      await Future.delayed(const Duration(milliseconds: 300));
      final totalFund = totalFundDummyList[_currentFundIndex];
      _currentFundIndex = (_currentFundIndex + 1) % totalFundDummyList.length;
      return totalFund;
    } catch (e) {
      _logger.e('Error fetching total fund', error: e);
      rethrow;
    }
  }
}
