import 'package:front/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:front/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:front/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/shared/data/models/dummy_data.dart';

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

    _activeWishlist = DummyData.getActiveProjects();
    _endedWishlist = DummyData.getEndedProjects();
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
      // 1. 활성 프로젝트에서 검색
      final activeIndex =
          _activeWishlist.indexWhere((item) => item.id == itemId);
      if (activeIndex != -1) {
        final item = _activeWishlist[activeIndex];
        if (!item.isLiked) {
          // 좋아요가 해제되어 있을 경우 다시 좋아요 처리
          _activeWishlist[activeIndex] = WishlistItemModel(
            id: item.id,
            title: item.title,
            description: item.description,
            companyName: item.companyName,
            imageUrl: item.imageUrl,
            fundingPercentage: item.fundingPercentage,
            fundingAmount: item.fundingAmount,
            remainingDays: item.remainingDays,
            isActive: item.isActive,
            isLiked: true,
          );
          return true;
        } else {
          // 좋아요가 설정되어 있을 경우 목록에서 제거
          _activeWishlist.removeAt(activeIndex);
          return false;
        }
      }

      // 2. 종료된 프로젝트에서 검색
      final endedIndex = _endedWishlist.indexWhere((item) => item.id == itemId);
      if (endedIndex != -1) {
        final item = _endedWishlist[endedIndex];
        if (!item.isLiked) {
          // 좋아요가 해제되어 있을 경우 다시 좋아요 처리
          _endedWishlist[endedIndex] = WishlistItemModel(
            id: item.id,
            title: item.title,
            description: item.description,
            companyName: item.companyName,
            imageUrl: item.imageUrl,
            fundingPercentage: item.fundingPercentage,
            fundingAmount: item.fundingAmount,
            remainingDays: item.remainingDays,
            isActive: item.isActive,
            isLiked: true,
          );
          return true;
        } else {
          // 좋아요가 설정되어 있을 경우 목록에서 제거
          _endedWishlist.removeAt(endedIndex);
          return false;
        }
      }

      return false;
    } catch (e) {
      LoggerUtil.e('❌ 좋아요 상태 변경 실패', e);
      throw Exception('좋아요 상태 변경에 실패했습니다: $e');
    }
  }

  /// 위시리스트에서 아이템 제거
  @override
  Future<bool> removeFromWishlist(int itemId) async {
    // toggleLike와 동일한 로직 (위시리스트에서는 토글과 제거가 같은 기능)
    return toggleLike(itemId);
  }
}
