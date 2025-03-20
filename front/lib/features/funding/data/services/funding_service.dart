import 'package:dio/dio.dart';
import '../models/funding_model.dart';

// 벡엔드 API가 아직 준비되지 않아서 잠시 주석처리
// class FundingService {
//   final Dio _dio = Dio();

//   Future<List<FundingModel>> fetchFundingList() async {
//     try {
//       final response =
//           await _dio.get('https://example.com/api/funding'); // 실제 API URL로 변경

//       if (response.statusCode == 200) {
//         List<dynamic> data = response.data;
//         return data.map((json) => FundingModel.fromJson(json)).toList();
//       } else {
//         throw Exception('Failed to load funding list');
//       }
//     } catch (e) {
//       throw Exception('Error fetching funding list: $e');
//     }
//   }
// }

class FundingService {
  Future<List<FundingModel>> fetchFundingList() async {
    // 🟢 백엔드 API 대신, 임시 데이터를 반환하는 코드
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 요청처럼 1초 딜레이

    List<Map<String, dynamic>> mockData = [
      {
        "id": 1,
        "title": "친환경 에너지 프로젝트",
        "description": "태양광 발전을 이용한 친환경 전기 생산",
        "imageUrl": "https://dummyimage.com/300x200/28a745/ffffff.png",
        "targetAmount": 50000,
        "currentAmount": 25000
      },
      {
        "id": 2,
        "title": "재활용 플라스틱 제품 개발",
        "description": "재활용 소재를 활용한 친환경 제품 제작",
        "imageUrl": "https://dummyimage.com/300x200/17a2b8/ffffff.png",
        "targetAmount": 80000,
        "currentAmount": 55000
      },
      {
        "id": 3,
        "title": "해양 플라스틱 정화 프로젝트",
        "description": "해양 쓰레기를 제거하여 해양 생태계를 보호합니다.",
        "imageUrl": "https://dummyimage.com/300x200/ffc107/ffffff.png",
        "targetAmount": 60000,
        "currentAmount": 30000
      },
      {
        "id": 4,
        "title": "태양광 랜턴 보급 프로젝트",
        "description": "전기가 부족한 지역에 태양광 랜턴을 보급합니다.",
        "imageUrl": "https://dummyimage.com/300x200/dc3545/ffffff.png",
        "targetAmount": 70000,
        "currentAmount": 40000
      },
      {
        "id": 5,
        "title": "도시 녹지 공간 확대",
        "description": "도시 내 녹지 공간을 확대하여 공기 질을 개선합니다.",
        "imageUrl": "https://dummyimage.com/300x200/6f42c1/ffffff.png",
        "targetAmount": 90000,
        "currentAmount": 45000
      },
      {
        "id": 6,
        "title": "전기차 충전소 확대",
        "description": "전기차 충전소를 늘려 친환경 차량 보급을 촉진합니다.",
        "imageUrl": "https://dummyimage.com/300x200/6610f2/ffffff.png",
        "targetAmount": 120000,
        "currentAmount": 60000
      },
      {
        "id": 7,
        "title": "친환경 농업 지원",
        "description": "유기농 농산물 생산을 장려하는 프로젝트입니다.",
        "imageUrl": "https://dummyimage.com/300x200/e83e8c/ffffff.png",
        "targetAmount": 50000,
        "currentAmount": 35000
      },
      {
        "id": 8,
        "title": "자전거 공유 시스템 개선",
        "description": "도시 내 자전거 공유 시스템을 업그레이드합니다.",
        "imageUrl": "https://dummyimage.com/300x200/20c997/ffffff.png",
        "targetAmount": 40000,
        "currentAmount": 20000
      },
      {
        "id": 9,
        "title": "쓰레기 재활용 촉진 프로젝트",
        "description": "재활용 시스템을 개선하여 쓰레기 문제를 해결합니다.",
        "imageUrl": "https://dummyimage.com/300x200/f8f9fa/212529.png",
        "targetAmount": 75000,
        "currentAmount": 50000
      },
      {
        "id": 10,
        "title": "친환경 포장재 개발",
        "description": "친환경적인 포장재 개발을 지원하는 프로젝트입니다.",
        "imageUrl": "https://dummyimage.com/300x200/343a40/ffffff.png",
        "targetAmount": 65000,
        "currentAmount": 30000
      }
    ];

    return mockData.map((json) => FundingModel.fromJson(json)).toList();
  }
}
