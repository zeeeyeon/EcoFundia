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
      final response = await _dio.get('/business/top-funding');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['content'] != null && data['content'] is List) {
          final List<dynamic> projectsList = data['content'];

          // 첫 번째 항목의 구조를 상세 로깅
          if (projectsList.isNotEmpty) {
            _logger.d('첫 번째 펀딩 항목 구조: ${projectsList[0]}');

            // 백엔드에서 제공하는 필드 확인 (isLiked는 제공하지 않음)
            final availableFields = projectsList[0].keys.toList();
            _logger.d('백엔드에서 제공되는 필드 목록: $availableFields');

            // isLiked 필드는 백엔드에서 제공하지 않음을 명확히 로깅
            _logger.d('📌 참고: isLiked 필드는 백엔드에서 제공하지 않음 (위시리스트 ID로 매칭 필요)');
          }

          final projects =
              projectsList.map((json) => ProjectDTO.fromJson(json)).toList();

          // 변환된 프로젝트 DTO 수 로깅
          _logger.d('변환된 프로젝트 DTO 수: ${projects.length}개');

          // 각 프로젝트 ID 목록 로깅 (위시리스트와 매칭하기 위함)
          final projectIds = projects.map((p) => p.fundingId).toList();
          _logger.d('프로젝트 ID 목록 (위시리스트 매칭용): $projectIds');

          return projects;
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
            final projectDTO = ProjectDTO.fromJson(projectData);
            _logger.d('ProjectDTO storyFileUrl: ${projectDTO.storyFileUrl}');
            _logger.d(
                'ProjectEntity storyFileUrl: ${projectDTO.toEntity().storyFileUrl}');
            return projectDTO;
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
      final response = await _dio.get('/business/total-fund');

      if (response.statusCode == 200) {
        final data = response.data;

        // 응답 데이터에서 content 필드 가져오기
        if (data['content'] != null) {
          return _parseTotalFund(data['content']);
        } else {
          _logger.e('❌ 유효하지 않은 API 응답 형식: content 필드 누락');
          throw Exception(
              'Invalid API response format: content field is missing');
        }
      } else {
        throw Exception('Failed to fetch total fund: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('❌ 네트워크 오류: 총 펀딩 금액 조회 실패', error: e);
      if (e.response != null) {
        _logger.e('응답 오류 데이터: ${e.response!.data}');
      }
      throw Exception('Network error when fetching total fund: ${e.message}');
    } catch (e) {
      _logger.e('❌ 총 펀딩 금액 조회 중 오류 발생', error: e);
      throw Exception('Error fetching total fund: $e');
    }
  }

  /// 다양한 형식의 totalFund 값을 파싱하는 헬퍼 메서드
  int _parseTotalFund(dynamic content) {
    try {
      int totalFund;

      if (content is int) {
        totalFund = content;
      } else if (content is double) {
        totalFund = content.toInt();
      } else if (content is String) {
        totalFund = int.tryParse(content) ?? 0;
      } else {
        _logger.w('⚠️ 예상치 못한 content 타입: ${content.runtimeType}, 기본값 0 사용');
        totalFund = 0;
      }

      _logger.d('🔢 파싱된 총 펀딩 금액: $totalFund');
      return totalFund;
    } catch (e) {
      _logger.e('❌ 총 펀딩 금액 파싱 중 오류', error: e);
      return 0; // 오류 발생 시 기본값 0 반환
    }
  }
}
