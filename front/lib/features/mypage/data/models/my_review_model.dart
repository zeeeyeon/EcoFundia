class MyReviewModel {
  final int reviewId;
  final int rating;
  final String content;
  final String title; // 펀딩 제목
  final String nickname; // 작성자 닉네임

  MyReviewModel({
    required this.reviewId,
    required this.rating,
    required this.content,
    required this.title,
    required this.nickname,
  });

  factory MyReviewModel.fromJson(Map<String, dynamic> json) {
    return MyReviewModel(
      reviewId: json['reviewId'],
      rating: json['rating'],
      content: json['content'],
      title: json['title'],
      nickname: json['nickname'],
    );
  }
}
