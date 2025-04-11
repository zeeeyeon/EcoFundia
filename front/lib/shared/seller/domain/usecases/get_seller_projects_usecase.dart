import 'package:front/shared/seller/domain/entities/seller_project_entity.dart';
import 'package:front/shared/seller/domain/repositories/seller_repository.dart';

/// 판매자의 프로젝트 목록 조회 UseCase
class GetSellerProjectsUseCase {
  final SellerRepository repository;

  GetSellerProjectsUseCase(this.repository);

  /// 모든 프로젝트 목록 조회 (execute 패턴)
  Future<List<SellerProjectEntity>> execute(int sellerId) async {
    // 활성 프로젝트와 종료된 프로젝트를 모두 가져옴
    final activeProjects = await repository.getActiveProjects(sellerId);
    final endedProjects = await repository.getEndedProjects(sellerId);

    // 활성 프로젝트를 우선 배치
    return [...activeProjects, ...endedProjects];
  }

  /// 진행 중인 프로젝트 목록 조회
  Future<List<SellerProjectEntity>> getActiveProjects(int sellerId) async {
    return await repository.getActiveProjects(sellerId);
  }

  /// 종료된 프로젝트 목록 조회
  Future<List<SellerProjectEntity>> getEndedProjects(int sellerId) async {
    return await repository.getEndedProjects(sellerId);
  }
}
