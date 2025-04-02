import 'package:dio/dio.dart';
import 'package:front/features/home/data/models/project_dto.dart';
import 'package:logger/logger.dart';

abstract class ProjectService {
  Future<List<ProjectDTO>> getProjects();
  Future<void> toggleProjectLike(int projectId, {bool? isCurrentlyLiked});
  Future<ProjectDTO> getProjectById(int projectId);
  Future<int> getTotalFund();
}

class ProjectApiService extends ProjectService {
  final Dio _dio;
  final Logger _logger;

  ProjectApiService(this._dio) : _logger = Logger();

  @override
  Future<List<ProjectDTO>> getProjects() async {
    try {
      _logger.d('Fetching top projects from API');

      final response = await _dio.get('/business/top-funding');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['content'] != null && data['content'] is List) {
          final List<dynamic> projectsList = data['content'];
          return projectsList.map((json) => ProjectDTO.fromJson(json)).toList();
        } else {
          throw Exception('Invalid API response format: content is not a list');
        }
      } else {
        throw Exception('Failed to fetch projects: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Dio error fetching projects', error: e);
      if (e.response != null) {
        _logger.e('Response error: ${e.response!.data}');
      }
      throw Exception('Network error when fetching projects: ${e.message}');
    } catch (e) {
      _logger.e('Error fetching projects', error: e);
      throw Exception('Error fetching projects: $e');
    }
  }

  @override
  Future<void> toggleProjectLike(int projectId,
      {bool? isCurrentlyLiked}) async {
    try {
      _logger.d(
          'Toggling like for project: $projectId (current status: ${isCurrentlyLiked ?? "unknown"})');

      // isCurrentlyLiked가 명시적으로 제공되지 않은 경우에만 API 호출로 상태 확인
      if (isCurrentlyLiked == null) {
        final project = await getProjectById(projectId);
        isCurrentlyLiked = project.isLiked;
        _logger.d(
            'Fetched current like status for project $projectId: $isCurrentlyLiked');
      }

      if (isCurrentlyLiked) {
        // 이미 찜한 상태면 찜 취소
        _logger.d('Currently liked, removing from wishlist: $projectId');
        final response = await _dio.delete('/user/wishList/$projectId');
        if (response.statusCode == 200) {
          _logger.i('Successfully removed from wishlist: $projectId');
        } else {
          _logger.w(
              'Unexpected status code when removing from wishlist: ${response.statusCode}');
        }
      } else {
        // 찜하지 않은 상태면 찜하기
        _logger.d('Currently not liked, adding to wishlist: $projectId');
        final response = await _dio.post('/user/wishList/$projectId');
        if (response.statusCode == 201) {
          _logger.i('Successfully added to wishlist: $projectId');
        } else {
          _logger.w(
              'Unexpected status code when adding to wishlist: ${response.statusCode}');
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        _logger.w('Item is already in wishlist: $projectId');
        // 이미 찜 목록에 있는 경우 (성공으로 간주)
      } else if (e.response?.statusCode == 404) {
        _logger.w('Item is not in wishlist: $projectId');
        // 찜 목록에 없는 경우 (이미 제거된 경우이므로 성공으로 간주)
      } else {
        _logger.e('Network error toggling project like', error: e);
        throw Exception('찜하기 요청 실패: ${e.message}');
      }
    } catch (e) {
      _logger.e('Error toggling project like', error: e);
      rethrow;
    }
  }

  @override
  Future<ProjectDTO> getProjectById(int projectId) async {
    try {
      _logger.d('Fetching project details: $projectId');

      // 실제 API 호출 구현
      final response = await _dio.get('/business/detail/$projectId');

      if (response.statusCode == 200) {
        final data = response.data;
        _logger.d('Project detail API response: $data');

        if (data['content'] != null) {
          // API 응답 구조 처리
          final content = data['content'];

          // fundingInfo와 sellerInfo를 병합하여 단일 맵으로 만듦
          if (content['fundingInfo'] != null && content['sellerInfo'] != null) {
            final fundingInfo = content['fundingInfo'] as Map<String, dynamic>;
            final sellerInfo = content['sellerInfo'] as Map<String, dynamic>;

            // 두 객체를 병합
            final projectData = {
              ...fundingInfo,
              'sellerName': sellerInfo['sellerName'],
              'sellerProfileImageUrl': sellerInfo['sellerProfileImageUrl'],
              'storyFileUrl': fundingInfo['storyFileUrl'],
            };

            _logger.d('Merged project data for DTO: $projectData');
            return ProjectDTO.fromJson(projectData);
          } else {
            throw Exception(
                'Invalid API response format: fundingInfo or sellerInfo is missing');
          }
        } else {
          throw Exception(
              'Invalid API response format: content is null or missing');
        }
      } else {
        throw Exception(
            'Failed to fetch project details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Dio error fetching project details', error: e);
      if (e.response != null) {
        _logger.e('Response error: ${e.response!.data}');
      }
      throw Exception(
          'Network error when fetching project details: ${e.message}');
    } catch (e) {
      _logger.e('Error fetching project details', error: e);
      rethrow;
    }
  }

  @override
  Future<int> getTotalFund() async {
    try {
      _logger.d('Fetching total fund from API');

      final response = await _dio.get('/business/total-fund');

      if (response.statusCode == 200) {
        final data = response.data;

        // 전체 응답 로깅
        _logger.d('Total fund API response: $data');

        // content 필드가 있고 정수값인지 확인
        if (data['content'] != null) {
          // int 타입 확인 및 변환
          final content = data['content'];
          int totalFund;

          if (content is int) {
            totalFund = content;
          } else if (content is double) {
            totalFund = content.toInt();
          } else if (content is String) {
            totalFund = int.tryParse(content) ?? 0;
          } else {
            _logger.e('Unexpected content type: ${content.runtimeType}');
            totalFund = 0;
          }

          _logger.d('Parsed total fund: $totalFund');
          return totalFund;
        } else {
          _logger.e('Invalid API response format: content is null or missing');
          throw Exception(
              'Invalid API response format: content is null or missing');
        }
      } else {
        _logger.e('Failed to fetch total fund: ${response.statusCode}');
        throw Exception('Failed to fetch total fund: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Dio error fetching total fund', error: e);
      if (e.response != null) {
        _logger.e('Response error: ${e.response!.data}');
      }
      throw Exception('Network error when fetching total fund: ${e.message}');
    } catch (e) {
      _logger.e('Error fetching total fund', error: e);
      throw Exception('Error fetching total fund: $e');
    }
  }
}
