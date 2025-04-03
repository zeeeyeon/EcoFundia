import 'package:front/core/services/api_service.dart';
import 'package:front/shared/seller/data/models/seller_model.dart';
import 'package:front/shared/seller/data/models/review_model.dart';
import 'package:front/shared/seller/domain/entities/seller_entity.dart';
import 'package:front/shared/seller/domain/entities/review_entity.dart';
import 'package:front/shared/seller/domain/entities/seller_project_entity.dart';
import 'package:front/shared/seller/domain/repositories/seller_repository.dart';
import 'package:front/utils/logger_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

/// 판매자 정보 로드 관련 예외 클래스
class SellerException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetwork;

  SellerException(this.message, {this.statusCode, this.isNetwork = false});

  @override
  String toString() => message;
}

/// 판매자 정보 리포지토리 구현체
class SellerRepositoryImpl implements SellerRepository {
  final ApiService _apiService;

  SellerRepositoryImpl(this._apiService);

  /// 판매자 상세 정보 조회
  @override
  Future<SellerEntity> getSellerDetails(int sellerId) async {
    try {
      LoggerUtil.i('🔄 판매자 정보 요청: ID $sellerId');

      // 실제 API 호출 - 명세서에 맞게 경로 수정 (/api/business/seller/detail/{sellerId})
      final response =
          await _apiService.get('/business/seller/detail/$sellerId');

      // 응답 데이터 검증 및 안전한 접근
      if (response.statusCode == 200) {
        final dynamic content = response.data['content'];

        if (content != null) {
          LoggerUtil.d('✅ 판매자 정보 응답: $content');
          try {
            // 새로운 API 응답 구조에 맞게 SellerModel 생성 (오타 처리 포함)
            final sellerData = {
              'id': content['sellerld'] ??
                  content['sellerId'] ??
                  0, // API 명세서 오타 'sellerld' 처리
              'name': content['sellerName'] ?? '이름 없음',
              'profileImageUrl': content['sellerProfilelmageUrl'] ??
                  content[
                      'sellerProfileImageUrl'], // API 명세서 오타 'sellerProfilelmageUrl' 처리
              'satisfaction': content['totalRating'] ?? 0.0,
              'reviewCount': content['ratingCount'] ?? 0,
              'totalFundingAmount': content['totalAmount']?.toString() ?? '0',
              'likeCount': content['wishlistCount'] ?? 0,
              'isMaker': false, // API에서 제공하지 않으므로 기본값 설정
              'isTop100': false, // API에서 제공하지 않으므로 기본값 설정
            };

            // 프로젝트 목록 저장 (필요시 ViewModel에서 사용)
            if (content['onGoingFunding'] != null) {
              _saveActiveProjects(sellerId, content['onGoingFunding']);
            }
            if (content['finishFunding'] != null) {
              _saveEndedProjects(sellerId, content['finishFunding']);
            }

            return SellerModel.fromJson(sellerData);
          } catch (e) {
            LoggerUtil.e('⚠️ 판매자 데이터 변환 오류', e);
            throw SellerException('판매자 정보 처리 중 오류가 발생했습니다. 다시 시도해 주세요.');
          }
        } else {
          // content가 null인 경우
          LoggerUtil.w('⚠️ 판매자 API 응답에 content가 없음: ${response.data}');
          throw SellerException('판매자 정보가 없습니다. 다시 시도해 주세요.',
              statusCode: response.statusCode);
        }
      } else {
        // 상태 코드가 200이 아닌 경우
        LoggerUtil.w('⚠️ 판매자 API 응답 오류: ${response.statusCode}');
        throw SellerException('서버에서 판매자 정보를 가져오지 못했습니다. 다시 시도해 주세요.',
            statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      LoggerUtil.e('❌ 판매자 정보 API 오류', e);

      // 네트워크 오류 상세 정보 로깅
      if (e.response != null) {
        LoggerUtil.d('API 응답: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        LoggerUtil.d('네트워크 오류 세부 정보: ${e.message}');
      }

      // 네트워크 오류 발생
      throw SellerException('네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.',
          statusCode: e.response?.statusCode, isNetwork: true);
    } catch (e) {
      LoggerUtil.e('❌ 판매자 정보 로드 실패', e);
      throw SellerException('판매자 정보를 불러오는데 실패했습니다: $e');
    }
  }

  // 진행 중인 프로젝트를 메모리에 캐싱
  List<SellerProjectEntity>? _cachedActiveProjects;
  int? _cachedActiveProjectsSellerId;

  // 종료된 프로젝트를 메모리에 캐싱
  List<SellerProjectEntity>? _cachedEndedProjects;
  int? _cachedEndedProjectsSellerId;

  // 진행 중인 프로젝트 저장
  void _saveActiveProjects(int sellerId, List<dynamic> projects) {
    _cachedActiveProjectsSellerId = sellerId;
    _cachedActiveProjects = _convertProjects(projects, true);
    LoggerUtil.d('✅ 진행 중인 프로젝트 캐싱 완료: ${_cachedActiveProjects?.length}개');
  }

  // 종료된 프로젝트 저장
  void _saveEndedProjects(int sellerId, List<dynamic> projects) {
    _cachedEndedProjectsSellerId = sellerId;
    _cachedEndedProjects = _convertProjects(projects, false);
    LoggerUtil.d('✅ 종료된 프로젝트 캐싱 완료: ${_cachedEndedProjects?.length}개');
  }

  // 프로젝트 JSON을 SellerProjectEntity로 변환
  List<SellerProjectEntity> _convertProjects(
      List<dynamic> projectList, bool isActive) {
    return projectList
        .map((json) {
          try {
            // 새로운 API 응답 구조에 맞게 데이터 변환 (오타 처리 포함)
            final projectData = {
              'id': json['fundingld'] ??
                  json['fundingId'] ??
                  0, // API 명세서 오타 'fundingld' 처리
              'title': json['title'] ?? '제목 없음',
              'companyName': '회사명', // API에서 제공하지 않으므로 기본값 설정
              'imageUrl': json['imageUrl'] ??
                  json['imageUrls']?[0] ??
                  'https://via.placeholder.com/150',
              'fundingPercentage': json['rate'] ?? 0.0,
              'fundingAmount': json['price']?.toString() ?? '0',
              'remainingDays': json['remainingDays'] ?? 0,
              'isActive': isActive,
            };
            return SellerProjectModel.fromJson(projectData);
          } catch (e) {
            LoggerUtil.w('⚠️ 프로젝트 데이터 변환 오류: $e');
            return null;
          }
        })
        .whereType<SellerProjectEntity>()
        .toList();
  }

  /// 진행 중인 프로젝트 목록 조회
  @override
  Future<List<SellerProjectEntity>> getActiveProjects(int sellerId) async {
    // 캐시에 진행 중인 프로젝트가 있고 동일한 판매자 ID면 캐시 사용
    if (_cachedActiveProjects != null &&
        _cachedActiveProjectsSellerId == sellerId) {
      LoggerUtil.i('🔄 진행 중인 프로젝트 캐시 사용: ID $sellerId');
      return _cachedActiveProjects!;
    }

    try {
      LoggerUtil.i('🔄 판매자 진행 중 프로젝트 요청: ID $sellerId');

      // 판매자 정보 재조회 (프로젝트 목록 포함)
      await getSellerDetails(sellerId);

      // 캐시에서 데이터 반환
      if (_cachedActiveProjects != null) {
        return _cachedActiveProjects!;
      }

      // 캐시에 없는 경우 빈 목록 반환
      return [];
    } catch (e) {
      LoggerUtil.e('❌ 판매자 진행 중 프로젝트 로드 실패', e);

      // 원본 예외를 그대로 전파하여 상위 계층에서 처리할 수 있도록 함
      if (e is SellerException) {
        rethrow;
      }

      throw SellerException('진행 중인 프로젝트 목록을 불러오는데 실패했습니다. 다시 시도해 주세요.');
    }
  }

  /// 종료된 프로젝트 목록 조회
  @override
  Future<List<SellerProjectEntity>> getEndedProjects(int sellerId) async {
    // 캐시에 종료된 프로젝트가 있고 동일한 판매자 ID면 캐시 사용
    if (_cachedEndedProjects != null &&
        _cachedEndedProjectsSellerId == sellerId) {
      LoggerUtil.i('🔄 종료된 프로젝트 캐시 사용: ID $sellerId');
      return _cachedEndedProjects!;
    }

    try {
      LoggerUtil.i('🔄 판매자 종료된 프로젝트 요청: ID $sellerId');

      // 판매자 정보 재조회 (프로젝트 목록 포함)
      await getSellerDetails(sellerId);

      // 캐시에서 데이터 반환
      if (_cachedEndedProjects != null) {
        return _cachedEndedProjects!;
      }

      // 캐시에 없는 경우 빈 목록 반환
      return [];
    } catch (e) {
      LoggerUtil.e('❌ 판매자 종료된 프로젝트 로드 실패', e);

      // 원본 예외를 그대로 전파하여 상위 계층에서 처리할 수 있도록 함
      if (e is SellerException) {
        rethrow;
      }

      throw SellerException('종료된 프로젝트 목록을 불러오는데 실패했습니다. 다시 시도해 주세요.');
    }
  }

  /// 리뷰 목록 조회
  @override
  Future<List<ReviewEntity>> getSellerReviews(int sellerId) async {
    try {
      LoggerUtil.i('🔄 판매자 리뷰 요청: ID $sellerId');

      // API 요청 파라미터 설정 - 쿼리 파라미터로 변경
      final Map<String, dynamic> params = {
        'sellerId': sellerId,
        'page': 1, // 첫 페이지부터 시작 (0부터 시작)
      };

      // 명세서에 맞게 경로 수정 (/api/business/review/)
      final response =
          await _apiService.get('/business/review', queryParameters: params);

      if (response.statusCode == 200) {
        final dynamic content = response.data['content'];

        if (content != null) {
          LoggerUtil.d('✅ 판매자 리뷰 응답: $content');

          // 리뷰가 없는 경우 - 정상적인 빈 목록 반환
          final reviews = content['reviews'];
          if (reviews == null || reviews.isEmpty) {
            LoggerUtil.i('리뷰 데이터가 없음');
            return [];
          }

          // 안전한 데이터 변환 (오타 처리 포함)
          return (reviews as List)
              .map((json) {
                try {
                  // 새로운 API 응답 구조에 맞게 데이터 변환
                  final reviewData = {
                    'id': json['reviewld'] ??
                        json['reviewId'] ??
                        0, // API 명세서 오타 'reviewld' 처리
                    'userName': json['nickname'] ?? '사용자',
                    'rating': json['rating'] ?? 0.0,
                    'content': json['content'] ?? '',
                    'productName': json['title'] ?? '상품명 없음',
                    'userId': json['userld'] ??
                        json['userId'] ??
                        0, // API 명세서 오타 'userld' 처리
                    'fundingId': json['fundingld'] ??
                        json['fundingId'] ??
                        0, // API 명세서 오타 'fundingld' 처리
                    'createdAt': DateTime.now()
                        .toIso8601String(), // API에서 제공하지 않으므로 현재 시간 사용
                  };
                  return ReviewModel.fromJson(reviewData);
                } catch (e) {
                  LoggerUtil.w('⚠️ 리뷰 데이터 변환 오류: $e');
                  return null;
                }
              })
              .whereType<ReviewEntity>()
              .toList();
        } else {
          LoggerUtil.w('⚠️ 판매자 리뷰 API 응답 형식 오류: ${response.data}');
          throw SellerException('리뷰 정보 형식이 올바르지 않습니다. 다시 시도해 주세요.');
        }
      } else {
        LoggerUtil.w('⚠️ 판매자 리뷰 API 응답 오류: ${response.statusCode}');
        throw SellerException('서버에서 리뷰 정보를 가져오지 못했습니다. 다시 시도해 주세요.',
            statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      LoggerUtil.e('❌ 판매자 리뷰 API 오류', e);

      // 네트워크 오류 상세 정보 로깅
      if (e.response != null) {
        LoggerUtil.d('API 응답: ${e.response?.statusCode} - ${e.response?.data}');
      }

      throw SellerException('네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.',
          statusCode: e.response?.statusCode, isNetwork: true);
    } catch (e) {
      LoggerUtil.e('❌ 판매자 리뷰 로드 실패', e);

      // 원본 예외를 그대로 전파하여 상위 계층에서 처리할 수 있도록 함
      if (e is SellerException) {
        rethrow;
      }

      throw SellerException('리뷰 정보를 불러오는데 실패했습니다. 다시 시도해 주세요.');
    }
  }
}

/// 판매자 레포지토리 프로바이더
final sellerRepositoryProvider = Provider<SellerRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SellerRepositoryImpl(apiService);
});
