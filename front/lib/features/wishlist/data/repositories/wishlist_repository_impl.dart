import 'package:front/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:front/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:front/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/shared/dummy/data/wishlist_dummy.dart';

/// 위시리스트 리포지토리 구현
class WishlistRepositoryImpl implements WishlistRepository {
  final ApiService _apiService;

  // 더미 데이터 초기화 (복사본을 사용하여 수정 가능하게 함)
  List<WishlistItemModel> _activeWishlist = [];
  List<WishlistItemModel> _endedWishlist = [];

  bool _isInitialized = false;

  WishlistRepositoryImpl({
    required ApiService apiService,
  }) : _apiService = apiService;

  /// 더미 데이터 초기화
  void _initDummyData() {
    if (_isInitialized) return;

    _activeWishlist = List.from(activeWishlistDummyList);
    _endedWishlist = List.from(endedWishlistDummyList);
    _isInitialized = true;
  }

  /// 진행 중인 펀딩 위시리스트 조회
  @override
  Future<List<WishlistItemEntity>> getActiveWishlist() async {
    try {
      // API 연동 전까지는 더미 데이터 사용
      // final response = await _apiService.get('/wishlist/active');
      // final List<dynamic> items = response.data['items'];
      // final List<WishlistItemModel> wishlistItems = items
      //     .map((item) => WishlistItemModel.fromJson(item as Map<String, dynamic>))
      //     .toList();
      // return wishlistItems;

      _initDummyData();
      LoggerUtil.i('✅ 진행 중인 펀딩 위시리스트 조회 완료: ${_activeWishlist.length}개');
      return _activeWishlist;
    } catch (e) {
      LoggerUtil.e('❌ 진행 중인 펀딩 위시리스트 조회 실패', e);
      throw Exception('위시리스트 조회에 실패했습니다: $e');
    }
  }

  /// 종료된 펀딩 위시리스트 조회
  @override
  Future<List<WishlistItemEntity>> getEndedWishlist() async {
    try {
      // API 연동 전까지는 더미 데이터 사용
      // final response = await _apiService.get('/wishlist/ended');
      // final List<dynamic> items = response.data['items'];
      // final List<WishlistItemModel> wishlistItems = items
      //     .map((item) => WishlistItemModel.fromJson(item as Map<String, dynamic>))
      //     .toList();
      // return wishlistItems;

      _initDummyData();
      LoggerUtil.i('✅ 종료된 펀딩 위시리스트 조회 완료: ${_endedWishlist.length}개');
      return _endedWishlist;
    } catch (e) {
      LoggerUtil.e('❌ 종료된 펀딩 위시리스트 조회 실패', e);
      throw Exception('위시리스트 조회에 실패했습니다: $e');
    }
  }

  /// 위시리스트 아이템의 좋아요 상태 토글
  @override
  Future<bool> toggleLike(int itemId) async {
    try {
      _initDummyData();
      final activeIndex =
          _activeWishlist.indexWhere((item) => item.id == itemId);
      final endedIndex = _endedWishlist.indexWhere((item) => item.id == itemId);

      if (activeIndex != -1) {
        final item = _activeWishlist[activeIndex];
        if (!item.isLiked) {
          _activeWishlist[activeIndex] = item.copyWith(isLiked: true);
          return true;
        } else {
          _activeWishlist.removeAt(activeIndex);
          return false;
        }
      } else if (endedIndex != -1) {
        final item = _endedWishlist[endedIndex];
        if (!item.isLiked) {
          _endedWishlist[endedIndex] = item.copyWith(isLiked: true);
          return true;
        } else {
          _endedWishlist.removeAt(endedIndex);
          return false;
        }
      }

      LoggerUtil.i('✅ 위시리스트 좋아요 토글 완료: $itemId');
      return false;
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 좋아요 토글 실패', e);
      throw Exception('위시리스트 좋아요 토글에 실패했습니다: $e');
    }
  }

  /// 위시리스트에서 아이템 제거
  @override
  Future<bool> removeFromWishlist(int itemId) async {
    // toggleLike와 동일한 로직 (위시리스트에서는 토글과 제거가 같은 기능)
    return toggleLike(itemId);
  }
}
