import 'package:front/core/services/api_service.dart';
import 'package:front/shared/data/models/dummy_data.dart';
import 'package:front/shared/seller/data/models/seller_model.dart';
import 'package:front/shared/seller/data/models/review_model.dart';
import 'package:front/shared/seller/domain/entities/seller_entity.dart';
import 'package:front/shared/seller/domain/entities/review_entity.dart';
import 'package:front/shared/seller/domain/entities/seller_project_entity.dart';
import 'package:front/shared/seller/domain/repositories/seller_repository.dart';

/// 판매자 정보 리포지토리 구현체
class SellerRepositoryImpl implements SellerRepository {
  final ApiService _apiService;

  SellerRepositoryImpl(this._apiService);

  /// 판매자 상세 정보 조회
  @override
  Future<SellerEntity> getSellerDetails(int sellerId) async {
    try {
      // 실제 API 호출
      // final response = await _apiService.get('/seller/$sellerId');
      // return SellerModel.fromJson(response.data);

      // 더미 데이터 사용 (API 연동 전)
      return DummyData.getSeller();
    } catch (e) {
      throw Exception('판매자 정보를 불러오는데 실패했습니다: $e');
    }
  }

  /// 진행 중인 프로젝트 목록 조회
  @override
  Future<List<SellerProjectEntity>> getActiveProjects(int sellerId) async {
    try {
      // 실제 API 호출
      // final response = await _apiService.get('/seller/$sellerId/projects/active');
      // return (response.data as List).map((e) => SellerProjectModel.fromJson(e)).toList();

      // 더미 데이터 사용 (API 연동 전)
      return DummyData.getActiveSellerProjects();
    } catch (e) {
      throw Exception('진행 중인 프로젝트 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 종료된 프로젝트 목록 조회
  @override
  Future<List<SellerProjectEntity>> getEndedProjects(int sellerId) async {
    try {
      // 실제 API 호출
      // final response = await _apiService.get('/seller/$sellerId/projects/ended');
      // return (response.data as List).map((e) => SellerProjectModel.fromJson(e)).toList();

      // 더미 데이터 사용 (API 연동 전)
      return DummyData.getEndedSellerProjects();
    } catch (e) {
      throw Exception('종료된 프로젝트 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 리뷰 목록 조회
  @override
  Future<List<ReviewEntity>> getSellerReviews(int sellerId) async {
    try {
      // 실제 API 호출
      // final response = await _apiService.get('/seller/$sellerId/reviews');
      // return (response.data as List).map((e) => ReviewModel.fromJson(e)).toList();

      // 더미 데이터 사용 (API 연동 전)
      return DummyData.getSellerReviews();
    } catch (e) {
      throw Exception('리뷰 목록을 불러오는데 실패했습니다: $e');
    }
  }
}
