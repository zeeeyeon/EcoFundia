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
        "imageUrl": "https://example.com/image1.jpg",
        "targetAmount": 50000,
        "currentAmount": 25000
      },
      {
        "id": 2,
        "title": "재활용 플라스틱 제품 개발",
        "description": "재활용 소재를 활용한 친환경 제품 제작",
        "imageUrl": "https://example.com/image2.jpg",
        "targetAmount": 80000,
        "currentAmount": 55000
      }
    ];

    return mockData.map((json) => FundingModel.fromJson(json)).toList();
  }
}
