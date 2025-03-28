import 'package:front/features/wishlist/data/models/wishlist_item_model.dart';

/// 진행중인 프로젝트(펀딩) 더미 데이터
const List<WishlistItemModel> activeWishlistDummyList = [
  WishlistItemModel(
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
  WishlistItemModel(
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
  WishlistItemModel(
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

/// 종료된 프로젝트(펀딩) 더미 데이터
const List<WishlistItemModel> endedWishlistDummyList = [
  WishlistItemModel(
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
  WishlistItemModel(
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
