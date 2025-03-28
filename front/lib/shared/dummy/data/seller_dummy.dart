import 'package:front/shared/seller/data/models/seller_model.dart';
import 'package:front/shared/seller/data/models/review_model.dart';

/// 판매자(메이커) 더미 데이터
const sellerDummy = SellerModel(
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

/// 판매자 리뷰 더미 데이터
final List<ReviewModel> sellerReviewDummyList = [
  ReviewModel(
    id: 1,
    userName: '도**',
    rating: 4.0,
    content: '집에 여러 기계 있는데, 이거 짱 좋아요. 하지만 디자인이 아쉽기 때문에 -1점 입니다. ㅎㅎ 앞으로도 화이팅!',
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
    content: '집에 여러 기계 있는데, 이거 짱 좋아요. 하지만 디자인이 아쉽기 때문에 -1점 입니다. ㅎㅎ 앞으로도 화이팅!',
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
