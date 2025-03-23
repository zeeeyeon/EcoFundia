// lib/features/mypage/data/services/my_funding_service.dart

import '../models/my_funding_model.dart';

class MyFundingService {
  Future<List<MyFundingModel>> fetchMyFundings() async {
    // 🔥 Mok 데이터
    final List<Map<String, dynamic>> mockJsonList = [
      {
        "fundingId": 1,
        "title": "제로웨이스트 키트",
        "description": "환경을 생각하는 일상용품 모음",
        "imageUrl": "[\"https://example.com/image1.jpg\"]",
        "endDate": "2025-04-20T23:59:59.000Z",
        "currentAmount": 300000,
        "category": "생활",
        "status": "진행중",
        "rate": 60,
        "totalPrice": 15000
      },
      {
        "fundingId": 2,
        "title": "친환경 텀블러",
        "description": "지구를 위한 작은 습관",
        "imageUrl": "[\"https://example.com/image2.jpg\"]",
        "endDate": "2025-04-25T23:59:59.000Z",
        "currentAmount": 500000,
        "category": "주방",
        "status": "진행중",
        "rate": 85,
        "totalPrice": 20000
      }
    ];

    // JSON → 모델 변환
    return mockJsonList.map((json) => MyFundingModel.fromJson(json)).toList();
  }
}
