import '../models/my_review_model.dart';

class MyReviewService {
  Future<List<MyReviewModel>> fetchMyReviews() async {
    // 실제 요청 전에는 잠깐 로딩 느낌 내기 (흉내용)
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock 응답
    final mockJson = {
      "status": {"code": "SU", "message": "Success"},
      "content": {
        "reviews": [
          {
            "reviewId": 1,
            "rating": 5,
            "content": "정말 신선하고 맛있어요! 건강한 식사를 할 수 있어서 만족합니다.",
            "nickname": "test02",
            "title": "프리미엄 유기농 샐러드"
          },
          {
            "reviewId": 2,
            "rating": 4,
            "content": "육포가 맛있긴 한데 가격이 조금 비싸네요.",
            "nickname": "test02",
            "title": "특제 한우 육포"
          }
        ]
      }
    };

    final reviewsJson = (mockJson['content']?['reviews'] ?? []) as List;
    return reviewsJson.map((json) => MyReviewModel.fromJson(json)).toList();
  }
}
