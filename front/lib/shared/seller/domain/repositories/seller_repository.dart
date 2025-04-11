import 'package:front/shared/seller/domain/entities/seller_entity.dart';
import 'package:front/shared/seller/domain/entities/review_entity.dart';
import 'package:front/shared/seller/domain/entities/seller_project_entity.dart';

/// 판매자 정보 조회를 위한 리포지토리 인터페이스
abstract class SellerRepository {
  /// 판매자 상세 정보 조회
  Future<SellerEntity> getSellerDetails(int sellerId);

  /// 판매자의 진행 중인 프로젝트 목록 조회
  Future<List<SellerProjectEntity>> getActiveProjects(int sellerId);

  /// 판매자의 종료된 프로젝트 목록 조회
  Future<List<SellerProjectEntity>> getEndedProjects(int sellerId);

  /// 판매자의 리뷰 목록 조회
  Future<List<ReviewEntity>> getSellerReviews(int sellerId);
}
