import 'package:dio/dio.dart';
import 'package:front/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:front/utils/logger_util.dart';

/// 위시리스트 API 서비스 인터페이스
abstract class WishlistService {
  /// 진행중인 위시리스트 조회
  Future<List<WishlistItemModel>> fetchActiveWishlist(
      {int page = 0, int size = 10});

  /// 종료된 위시리스트 조회
  Future<List<WishlistItemModel>> fetchEndedWishlist(
      {int page = 0, int size = 10});

  /// 위시리스트에 추가
  Future<void> addToWishlist(int fundingId);

  /// 위시리스트에서 제거
  Future<void> removeFromWishlist(int fundingId);
}

/// 위시리스트 API 서비스 구현
class WishlistApiService implements WishlistService {
  final Dio _dio;

  WishlistApiService(this._dio);

  @override
  Future<List<WishlistItemModel>> fetchActiveWishlist(
      {int page = 0, int size = 10}) async {
    try {
      LoggerUtil.d('🔍 진행중인 위시리스트 조회 요청');

      final response = await _dio.get(
        '/user/wishList/ongoing',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        LoggerUtil.d('✅ 위시리스트(진행중) 응답: $data');

        if (data != null &&
            data['content'] != null &&
            data['content']['content'] is List) {
          final List<dynamic> wishlistData = data['content']['content'];
          final items = wishlistData
              .map((item) => WishlistItemModel.fromJson(item))
              .toList();

          // 페이지네이션 정보 로깅
          final totalElements = data['content']['totalElements'] as int? ?? 0;
          final totalPages = data['content']['totalPages'] as int? ?? 0;
          final currentPage = data['content']['page'] as int? ?? 0;

          LoggerUtil.i(
              '📚 위시리스트(진행중) ${items.length}개 조회 완료 (총 $totalElements개, $totalPages 페이지 중 $currentPage 페이지)');
          return items;
        } else {
          LoggerUtil.w('⚠️ 위시리스트(진행중) 데이터 형식 오류: ${data['content']}');
          return [];
        }
      } else {
        LoggerUtil.e('❌ 위시리스트(진행중) 조회 실패: ${response.statusCode}');
        throw Exception('위시리스트 조회에 실패했습니다: ${response.statusCode}');
      }
    } on DioException catch (e) {
      LoggerUtil.e('❌ 위시리스트(진행중) 조회 네트워크 오류', e);
      if (e.response != null) {
        LoggerUtil.e('📡 응답 데이터: ${e.response!.data}');
      }
      throw Exception('위시리스트 조회 중 네트워크 오류: ${e.message}');
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트(진행중) 조회 중 예상치 못한 오류', e);
      throw Exception('위시리스트 조회 중 오류: $e');
    }
  }

  @override
  Future<List<WishlistItemModel>> fetchEndedWishlist(
      {int page = 0, int size = 10}) async {
    try {
      LoggerUtil.d('🔍 종료된 위시리스트 조회 요청');

      final response = await _dio.get(
        '/user/wishList/done',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        LoggerUtil.d('✅ 위시리스트(종료) 응답: $data');

        if (data != null &&
            data['content'] != null &&
            data['content']['content'] is List) {
          final List<dynamic> wishlistData = data['content']['content'];
          final items = wishlistData
              .map((item) => WishlistItemModel.fromJson(item))
              .toList();

          // 페이지네이션 정보 로깅
          final totalElements = data['content']['totalElements'] as int? ?? 0;
          final totalPages = data['content']['totalPages'] as int? ?? 0;
          final currentPage = data['content']['page'] as int? ?? 0;

          LoggerUtil.i(
              '📚 위시리스트(종료) ${items.length}개 조회 완료 (총 $totalElements개, $totalPages 페이지 중 $currentPage 페이지)');
          return items;
        } else {
          LoggerUtil.w('⚠️ 위시리스트(종료) 데이터 형식 오류: ${data['content']}');
          return [];
        }
      } else {
        LoggerUtil.e('❌ 위시리스트(종료) 조회 실패: ${response.statusCode}');
        throw Exception('위시리스트 조회에 실패했습니다: ${response.statusCode}');
      }
    } on DioException catch (e) {
      LoggerUtil.e('❌ 위시리스트(종료) 조회 네트워크 오류', e);
      if (e.response != null) {
        LoggerUtil.e('📡 응답 데이터: ${e.response!.data}');
      }
      throw Exception('위시리스트 조회 중 네트워크 오류: ${e.message}');
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트(종료) 조회 중 예상치 못한 오류', e);
      throw Exception('위시리스트 조회 중 오류: $e');
    }
  }

  @override
  Future<void> addToWishlist(int fundingId) async {
    try {
      LoggerUtil.d('💾 위시리스트 추가 요청: $fundingId');

      final response = await _dio.post('/user/wishList/$fundingId');

      if (response.statusCode == 201) {
        LoggerUtil.i('✅ 위시리스트 추가 성공: $fundingId');
      } else {
        LoggerUtil.e('❌ 위시리스트 추가 실패: ${response.statusCode}');
        throw Exception('위시리스트 추가에 실패했습니다: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // 400 에러는 이미 찜한 상품일 수 있으므로 무시
      if (e.response?.statusCode == 400) {
        LoggerUtil.w('⚠️ 이미 찜한 상품입니다: $fundingId');
        return;
      }

      LoggerUtil.e('❌ 위시리스트 추가 네트워크 오류', e);
      if (e.response != null) {
        LoggerUtil.e('📡 응답 데이터: ${e.response!.data}');
      }
      throw Exception('위시리스트 추가 중 네트워크 오류: ${e.message}');
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 추가 중 예상치 못한 오류', e);
      throw Exception('위시리스트 추가 중 오류: $e');
    }
  }

  @override
  Future<void> removeFromWishlist(int fundingId) async {
    try {
      LoggerUtil.d('🗑️ 위시리스트 제거 요청: $fundingId');

      final response = await _dio.delete('/user/wishList/$fundingId');

      if (response.statusCode == 200) {
        LoggerUtil.i('✅ 위시리스트 제거 성공: $fundingId');
      } else {
        LoggerUtil.e('❌ 위시리스트 제거 실패: ${response.statusCode}');
        throw Exception('위시리스트 제거에 실패했습니다: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // 404 에러는 이미 찜 목록에 없는 경우일 수 있으므로 무시
      if (e.response?.statusCode == 404) {
        LoggerUtil.w('⚠️ 찜 목록에 없는 상품입니다: $fundingId');
        return;
      }

      LoggerUtil.e('❌ 위시리스트 제거 네트워크 오류', e);
      if (e.response != null) {
        LoggerUtil.e('📡 응답 데이터: ${e.response!.data}');
      }
      throw Exception('위시리스트 제거 중 네트워크 오류: ${e.message}');
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 제거 중 예상치 못한 오류', e);
      throw Exception('위시리스트 제거 중 오류: $e');
    }
  }
}
