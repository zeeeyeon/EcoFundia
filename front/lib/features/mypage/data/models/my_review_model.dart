class MyReviewModel {
  final int reviewId;
  final int rating;
  final String content;
  final String title; // 펀딩 제목
  final String nickname; // 작성자 닉네임
  final String description;
  final int totalPrice;
  final int fundingId; // ✅ 추가된 필드

  MyReviewModel({
    required this.reviewId,
    required this.rating,
    required this.content,
    required this.title,
    required this.nickname,
    required this.description,
    required this.totalPrice,
    required this.fundingId, // ✅ 생성자에 추가
  });

  factory MyReviewModel.fromJson(Map<String, dynamic> json) {
    return MyReviewModel(
      reviewId: json['reviewId'],
      rating: json['rating'],
      content: json['content'],
      title: json['title'],
      nickname: json['nickname'],
      description: json['description'] ?? '',
      totalPrice: json['totalPrice'] ?? 0,
      fundingId: json['fundingId'], // ✅ fromJson에 매핑 추가
    );
  }
}
