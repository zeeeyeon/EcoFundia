import 'package:front/features/home/data/models/project_dto.dart';

/// 프로젝트 더미 데이터 목록
const List<ProjectDTO> projectDummyList = [
  ProjectDTO(
    id: '1',
    title: '친환경 대나무 칫솔',
    description:
        '지구를 생각하는 당신을 위한 친환경 칫솔입니다. 100% 생분해 가능한 대나무로 제작되었으며, 환경을 생각하는 모든 분들께 추천드립니다.',
    imageUrl: 'assets/images/test01.png',
    percentage: 75.0,
    price: '15,000원',
    remainingTime: '3일 남음',
    isLiked: false,
  ),
  ProjectDTO(
    id: '2',
    title: '태양광 보조배터리',
    description: '태양광으로 충전하는 친환경 보조배터리입니다. 언제 어디서나 깨끗한 에너지로 당신의 기기를 충전하세요.',
    imageUrl: 'assets/images/test02.png',
    percentage: 45.0,
    price: '35,000원',
    remainingTime: '5일 남음',
    isLiked: true,
  ),
  ProjectDTO(
    id: '3',
    title: '업사이클링 가방',
    description: '버려지는 자동차 에어백으로 만든 프리미엄 업사이클링 가방입니다. 환경을 생각하는 새로운 패션을 제안합니다.',
    imageUrl: 'assets/images/test05.png',
    percentage: 90.0,
    price: '89,000원',
    remainingTime: '2일 남음',
    isLiked: false,
  ),
  ProjectDTO(
    id: '4',
    title: '생분해성 식물 화분',
    description: '사용 후 땅에 묻으면 자연분해되는 친환경 화분입니다. 식물을 키우면서 환경도 보호하세요.',
    imageUrl: 'assets/images/test04.png',
    percentage: 60.0,
    price: '8,900원',
    remainingTime: '8일 남음',
    isLiked: false,
  ),
  ProjectDTO(
    id: '5',
    title: '제로웨이스트 키트',
    description: '일상생활에서 쓰레기를 줄이는 데 필요한 모든 것을 담은 제로웨이스트 키트입니다.',
    imageUrl: 'assets/images/test03.png',
    percentage: 85.0,
    price: '45,000원',
    remainingTime: '4일 남음',
    isLiked: true,
  ),
];

/// 총 펀딩 금액 더미 데이터
const List<int> totalFundDummyList = [
  10000000, // 1천만원
  30000000, // 3천만원
  100000000, // 1억
  105000000, // 1억 5백만원
  110000000, // 1억 1천만원
  120000000, // 1억 2천만원
  135000000, // 1억 3천 5백만원
  150000000, // 1억 5천만원
  170000000, // 1억 7천만원
  200000000, // 2억
  250000000, // 2억 5천만원
  300000000, // 3억
];
