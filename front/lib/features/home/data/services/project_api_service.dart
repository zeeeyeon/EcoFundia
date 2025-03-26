import 'package:dio/dio.dart';
import 'package:front/features/home/data/models/project_dto.dart';
import 'package:front/features/home/data/services/project_service.dart';
import 'package:logger/logger.dart';

class ProjectApiService extends ProjectService {
  final Dio _dio;
  final Logger _logger;
  int _currentFundIndex = 0;
  final List<int> _dummyTotalFunds = [
    10000000,
    30000000,
    100000000, // 10억
    105000000, // 10억 5천
    110000000, // 11억
    120000000, // 12억
    135000000, // 13억 5천
    150000000, // 15억
    170000000, // 17억
    200000000, // 20억
    2500000000, // 25억
    3000000000, // 30억
  ];

  final List<ProjectDTO> _dummyProjects = [
    const ProjectDTO(
      id: '1',
      title: '친환경 대나무 칫솔',
      description:
          '지구를 생각하는 당신을 위한 친환경 칫솔입니다. 100% 생분해 가능한 대나무로 제작되었으며, 환경을 생각하는 모든 분들께 추천드립니다.',
      imageUrl: 'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04',
      percentage: 75.0,
      price: '15,000원',
      remainingTime: '3일 남음',
      isLiked: false,
    ),
    const ProjectDTO(
      id: '2',
      title: '태양광 보조배터리',
      description: '태양광으로 충전하는 친환경 보조배터리입니다. 언제 어디서나 깨끗한 에너지로 당신의 기기를 충전하세요.',
      imageUrl: 'https://images.unsplash.com/photo-1620827552723-4c3c021ea828',
      percentage: 45.0,
      price: '35,000원',
      remainingTime: '5일 남음',
      isLiked: true,
    ),
    const ProjectDTO(
      id: '3',
      title: '업사이클링 가방',
      description:
          '버려지는 자동차 에어백으로 만든 프리미엄 업사이클링 가방입니다. 환경을 생각하는 새로운 패션을 제안합니다.',
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62',
      percentage: 90.0,
      price: '89,000원',
      remainingTime: '2일 남음',
      isLiked: false,
    ),
    const ProjectDTO(
      id: '4',
      title: '생분해성 식물 화분',
      description: '사용 후 땅에 묻으면 자연분해되는 친환경 화분입니다. 식물을 키우면서 환경도 보호하세요.',
      imageUrl: 'https://images.unsplash.com/photo-1462530260150-162092dbf011',
      percentage: 60.0,
      price: '8,900원',
      remainingTime: '8일 남음',
      isLiked: false,
    ),
    const ProjectDTO(
      id: '5',
      title: '제로웨이스트 키트',
      description: '일상생활에서 쓰레기를 줄이는 데 필요한 모든 것을 담은 제로웨이스트 키트입니다.',
      imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09',
      percentage: 85.0,
      price: '45,000원',
      remainingTime: '4일 남음',
      isLiked: true,
    ),
  ];

  ProjectApiService(this._dio) : _logger = Logger();

  @override
  Future<List<ProjectDTO>> getProjects() async {
    try {
      _logger.d('Fetching projects from API');
      await Future.delayed(
          const Duration(milliseconds: 500)); // 실제 API 호출처럼 보이게 하기 위한 지연
      return _dummyProjects;
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
      final index = _dummyProjects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        _dummyProjects[index] = ProjectDTO(
          id: _dummyProjects[index].id,
          title: _dummyProjects[index].title,
          description: _dummyProjects[index].description,
          imageUrl: _dummyProjects[index].imageUrl,
          percentage: _dummyProjects[index].percentage,
          price: _dummyProjects[index].price,
          remainingTime: _dummyProjects[index].remainingTime,
          isLiked: !_dummyProjects[index].isLiked,
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
      final project = _dummyProjects.firstWhere(
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
      final totalFund = _dummyTotalFunds[_currentFundIndex];
      _currentFundIndex = (_currentFundIndex + 1) % _dummyTotalFunds.length;
      return totalFund;
    } catch (e) {
      _logger.e('Error fetching total fund', error: e);
      rethrow;
    }
  }
}
