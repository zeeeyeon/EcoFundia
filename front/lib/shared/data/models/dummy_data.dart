import 'package:front/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:front/shared/seller/data/models/seller_model.dart';
import 'package:front/shared/seller/data/models/review_model.dart';

/// 앱 전체에서 사용하는 공통 더미 데이터
class DummyData {
  /// 진행중인 프로젝트(펀딩) 더미 데이터
  static List<WishlistItemModel> getActiveProjects() {
    return [
      const WishlistItemModel(
        id: 101,
        title: "[노트북 보조 모니터] 모니터+ USB허브 게임 영상 주식을 한번에!",
        description: "게임, 영상, 주식을 한번에!",
        companyName: "김한민 컴퍼니",
        imageUrl: "https://picsum.photos/200/300",
        fundingPercentage: 5023.0,
        fundingAmount: "2,600만원++",
        remainingDays: "10일 남음",
        isActive: true,
        isLiked: true,
      ),
      const WishlistItemModel(
        id: 102,
        title: "[웨어러블 디바이스] 최신 스마트워치 건강관리의 시작",
        description: "건강 관리를 위한 최신 웨어러블 디바이스",
        companyName: "김한민 컴퍼니",
        imageUrl: "https://picsum.photos/200/300",
        fundingPercentage: 3250.0,
        fundingAmount: "1,800만원++",
        remainingDays: "5일 남음",
        isActive: true,
        isLiked: true,
      ),
      const WishlistItemModel(
        id: 103,
        title: "[인체공학 키보드] 손목 피로 제로! 타이핑의 혁명",
        description: "하루 종일 타이핑해도 손목 통증 없는 인체공학 키보드",
        companyName: "에르고텍",
        imageUrl: "https://picsum.photos/200/300",
        fundingPercentage: 378.5,
        fundingAmount: "1,892만원",
        remainingDays: "7일 남음",
        isActive: true,
        isLiked: true,
      ),
    ];
  }

  /// 종료된 프로젝트(펀딩) 더미 데이터
  static List<WishlistItemModel> getEndedProjects() {
    return [
      const WishlistItemModel(
        id: 201,
        title: "[뉴테크] 국내산+USB기능까지",
        description: "한국 기술의 자부심, 혁신적인 USB 멀티 기기",
        companyName: "김한민 컴퍼니",
        imageUrl: "https://picsum.photos/200/300",
        fundingPercentage: 10023.0,
        fundingAmount: "5,500만원+",
        remainingDays: "마감",
        isActive: false,
        isLiked: true,
      ),
      const WishlistItemModel(
        id: 202,
        title: "[무선 이어폰] 초경량 고음질 블루투스 이어폰",
        description: "24시간 재생, 노이즈 캔슬링 탑재",
        companyName: "사운드플렉스",
        imageUrl: "https://picsum.photos/200/300",
        fundingPercentage: 750.0,
        fundingAmount: "3,750만원",
        remainingDays: "마감",
        isActive: false,
        isLiked: true,
      ),
    ];
  }

  /// 판매자(메이커) 더미 데이터
  static SellerModel getSeller() {
    return const SellerModel(
      id: 1,
      name: '(주)김한민',
      profileImageUrl: 'https://picsum.photos/200/300',
      isMaker: true,
      isTop100: true,
      satisfaction: 4.5,
      reviewCount: 500,
      totalFundingAmount: '5,500만원+',
      likeCount: 1245,
    );
  }

  /// SellerProjectModel 타입으로 진행 중인 프로젝트 변환
  static List<SellerProjectModel> getActiveSellerProjects() {
    final activeProjects = getActiveProjects();

    return activeProjects
        .map((project) => SellerProjectModel(
              id: project.id,
              title: project.title,
              companyName: project.companyName,
              imageUrl: project.imageUrl,
              fundingPercentage: project.fundingPercentage,
              fundingAmount: project.fundingAmount,
              remainingDays: project.remainingDays,
              isActive: project.isActive,
            ))
        .toList();
  }

  /// SellerProjectModel 타입으로 종료된 프로젝트 변환
  static List<SellerProjectModel> getEndedSellerProjects() {
    final endedProjects = getEndedProjects();

    return endedProjects
        .map((project) => SellerProjectModel(
              id: project.id,
              title: project.title,
              companyName: project.companyName,
              imageUrl: project.imageUrl,
              fundingPercentage: project.fundingPercentage,
              fundingAmount: project.fundingAmount,
              remainingDays: project.remainingDays,
              isActive: project.isActive,
            ))
        .toList();
  }

  /// 판매자 리뷰 더미 데이터
  static List<ReviewModel> getSellerReviews() {
    return [
      ReviewModel(
        id: 1,
        userName: '도**',
        rating: 4.0,
        content:
            '집에 여러 기계 있는데, 이거 짱 좋아요. 하지만 디자인이 아쉽기 때문에 -1점 입니다. ㅎㅎ 앞으로도 화이팅!',
        productName: '[존맛탱구리1] 슈퍼바나나 맛도 슈퍼다!!',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ReviewModel(
        id: 2,
        userName: '도**',
        rating: 5.0,
        content: '집에 여러 기계 있는데, 이거 짱 좋아요.',
        productName: '[존맛탱구리2] 슈퍼바나나 맛도 슈퍼다!!',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      ReviewModel(
        id: 3,
        userName: '이**',
        rating: 5.0,
        content:
            '집에 여러 기계 있는데, 이거 짱 좋아요. 하지만 디자인이 아쉽기 때문에 -1점 입니다. ㅎㅎ 앞으로도 화이팅!',
        productName: '[존맛탱구리1] 슈퍼바나나 맛도 슈퍼다!!',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ReviewModel(
        id: 4,
        userName: '김**',
        rating: 3.0,
        content: '괜찮은 제품이지만 가격대비 성능이 조금 아쉬워요. 배송은 빨랐고 포장상태도 좋았습니다.',
        productName: '[인체공학 키보드] 손목 피로 제로! 타이핑의 혁명',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      ReviewModel(
        id: 5,
        userName: '박**',
        rating: 5.0,
        content: '정말 만족스러운 제품입니다! 배송도 빠르고 품질도 좋아요. 다음에도 이 브랜드 제품을 구매하고 싶어요.',
        productName: '[무선 이어폰] 초경량 고음질 블루투스 이어폰',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
    ];
  }
}
