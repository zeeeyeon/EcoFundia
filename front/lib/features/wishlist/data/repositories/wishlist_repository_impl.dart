import 'package:front/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:front/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:front/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:front/utils/logger_util.dart';

/// 위시리스트 리포지토리 구현
class WishlistRepositoryImpl implements WishlistRepository {
  // 임시 더미 데이터 (API 연동 전까지 사용)
  final List<WishlistItemModel> _dummyActiveWishlist = [
    const WishlistItemModel(
      id: 1,
      title: "[노트북 보조 모니터] 모니터+ USB 허브 게이밍",
      description: "게임, 영상, 주식을 한번에!",
      companyName: "김한민 컴퍼니",
      imageUrl: "assets/images/wishlist/product_image.png",
      fundingPercentage: 5023.0,
      fundingAmount: "2,600만원",
      remainingDays: "10일 남음",
      isActive: true,
      isLiked: true,
    ),
    const WishlistItemModel(
      id: 2,
      title: "[인체공학 키보드] 손목 피로 제로! 타이핑의 혁명",
      description: "하루 종일 타이핑해도 손목 통증 없는 인체공학 키보드",
      companyName: "에르고텍",
      imageUrl: "assets/images/wishlist/product_image.png",
      fundingPercentage: 378.5,
      fundingAmount: "1,892만원",
      remainingDays: "7일 남음",
      isActive: true,
      isLiked: true,
    ),
    const WishlistItemModel(
      id: 3,
      title: "[스마트 백팩] 도난방지 + USB 충전 + 방수기능",
      description: "출퇴근, 여행에 완벽한 3박자 백팩",
      companyName: "트래블프로",
      imageUrl: "assets/images/wishlist/product_image.png",
      fundingPercentage: 426.0,
      fundingAmount: "2,130만원",
      remainingDays: "15일 남음",
      isActive: true,
      isLiked: true,
    ),
  ];

  final List<WishlistItemModel> _dummyEndedWishlist = [
    const WishlistItemModel(
      id: 4,
      title: "[무선 이어폰] 초경량 고음질 블루투스 이어폰",
      description: "24시간 재생, 노이즈 캔슬링 탑재",
      companyName: "사운드플렉스",
      imageUrl: "assets/images/wishlist/product_image.png",
      fundingPercentage: 1250.0,
      fundingAmount: "6,250만원",
      remainingDays: "종료됨",
      isActive: false,
      isLiked: true,
    ),
    const WishlistItemModel(
      id: 5,
      title: "[스마트 플랜터] 식물 자동 관리 시스템",
      description: "바쁜 당신 대신 식물을 관리해드립니다",
      companyName: "그린라이프",
      imageUrl: "assets/images/wishlist/product_image.png",
      fundingPercentage: 682.0,
      fundingAmount: "3,410만원",
      remainingDays: "종료됨",
      isActive: false,
      isLiked: true,
    ),
  ];

  /// 진행 중 펀딩 위시리스트 아이템 조회
  @override
  Future<List<WishlistItemEntity>> getActiveWishlistItems() async {
    // 네트워크 요청 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 800));
    LoggerUtil.i('✅ 진행 중인 펀딩 위시리스트 조회 완료: ${_dummyActiveWishlist.length}개');
    return _dummyActiveWishlist;
  }

  /// 종료된 펀딩 위시리스트 아이템 조회
  @override
  Future<List<WishlistItemEntity>> getEndedWishlistItems() async {
    // 네트워크 요청 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 800));
    LoggerUtil.i('✅ 종료된 펀딩 위시리스트 조회 완료: ${_dummyEndedWishlist.length}개');
    return _dummyEndedWishlist;
  }

  /// 위시리스트 아이템 좋아요 상태 토글
  @override
  Future<bool> toggleWishlistItem(int itemId) async {
    // 네트워크 요청 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));

    // 활성 리스트에서 아이템 찾기
    final activeIndex =
        _dummyActiveWishlist.indexWhere((item) => item.id == itemId);
    if (activeIndex != -1) {
      final item = _dummyActiveWishlist[activeIndex];
      // 좋아요 취소 시 리스트에서 제거
      if (item.isLiked) {
        _dummyActiveWishlist.removeAt(activeIndex);
        LoggerUtil.i('✅ 위시리스트 아이템 제거 성공: ID $itemId');
      } else {
        // 실제로는 이 분기가 실행되지 않음 (이미 위시리스트에 있는 것은 항상 isLiked=true)
        final updatedItem = WishlistItemModel(
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
        _dummyActiveWishlist[activeIndex] = updatedItem;
        LoggerUtil.i('✅ 위시리스트 아이템 추가 성공: ID $itemId');
      }
      return true;
    }

    // 종료된 리스트에서 아이템 찾기
    final endedIndex =
        _dummyEndedWishlist.indexWhere((item) => item.id == itemId);
    if (endedIndex != -1) {
      final item = _dummyEndedWishlist[endedIndex];
      // 좋아요 취소 시 리스트에서 제거
      if (item.isLiked) {
        _dummyEndedWishlist.removeAt(endedIndex);
        LoggerUtil.i('✅ 위시리스트 아이템 제거 성공: ID $itemId');
      } else {
        // 실제로는 이 분기가 실행되지 않음
        final updatedItem = WishlistItemModel(
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
        _dummyEndedWishlist[endedIndex] = updatedItem;
        LoggerUtil.i('✅ 위시리스트 아이템 추가 성공: ID $itemId');
      }
      return true;
    }

    LoggerUtil.e('❌ 위시리스트 아이템을 찾을 수 없음: ID $itemId');
    return false;
  }

  /// 위시리스트에서 아이템 제거
  @override
  Future<bool> removeFromWishlist(int itemId) async {
    // toggleWishlistItem과 동일한 로직 (위시리스트에서는 토글과 제거가 같은 기능)
    return toggleWishlistItem(itemId);
  }
}
