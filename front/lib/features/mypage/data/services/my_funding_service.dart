import '../models/my_funding_model.dart';

class MyFundingService {
  Future<List<MyFundingModel>> fetchMyFundings() async {
    // 🔥 Mok 데이터
    final List<Map<String, dynamic>> mockJsonList = [
      {
        "totalPrice": 100000,
        "fundingId": 6,
        "title": "특제 한우 육포",
        "description": "프리미엄 한우로 만든 육포",
        "imageUrl":
            "[\"https://example.com/image1.jpg\", \"https://example.com/image2.jpg\"]",
        "endDate": "2025-04-20T23:59:59",
        "currentAmount": 2500000,
        "category": "FOOD",
        "status": "ONGOING",
        "rate": 71
      },
      {
        "totalPrice": 100000,
        "fundingId": 5,
        "title": "모던 디자인 벽시계",
        "description": "심플하면서 세련된 벽시계",
        "imageUrl":
            "[\"https://example.com/image9.jpg\", \"https://example.com/image10.jpg\"]",
        "endDate": "2025-04-15T23:59:59",
        "currentAmount": 4000000,
        "category": "INTERIOR",
        "status": "ONGOING",
        "rate": 80
      },
      {
        "totalPrice": 100000,
        "fundingId": 10,
        "title": "모던 디자인 테이블 램프",
        "description": "심플하고 세련된 디자인의 램프",
        "imageUrl":
            "[\"https://example.com/image9.jpg\", \"https://example.com/image10.jpg\"]",
        "endDate": "2025-04-12T23:59:59",
        "currentAmount": 3000000,
        "category": "INTERIOR",
        "status": "ONGOING",
        "rate": 66
      },
      {
        "totalPrice": 100000,
        "fundingId": 3,
        "title": "무선 블루투스 이어폰",
        "description": "고음질 무선 이어폰",
        "imageUrl":
            "[\"https://example.com/image5.jpg\", \"https://example.com/image6.jpg\"]",
        "endDate": "2025-04-10T23:59:59",
        "currentAmount": 3000000,
        "category": "ELECTRONICS",
        "status": "ONGOING",
        "rate": 30
      },
      {
        "totalPrice": 100000,
        "fundingId": 7,
        "title": "핸드메이드 가죽 벨트",
        "description": "장인의 손길로 제작한 가죽 벨트",
        "imageUrl":
            "[\"https://example.com/image3.jpg\", \"https://example.com/image4.jpg\"]",
        "endDate": "2025-04-10T23:59:59",
        "currentAmount": 1000000,
        "category": "FASHION",
        "status": "SUCCESS",
        "rate": 40
      }
    ];

    // JSON → 모델 변환
    return mockJsonList.map((json) => MyFundingModel.fromJson(json)).toList();
  }
}
