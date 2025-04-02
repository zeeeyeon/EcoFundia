class MyReviewModel {
  final int reviewId;
  final int rating;
  final String content;
  final String nickname;
  final int userId;
  final int fundingId;
  final String title; // 펀딩 제목

  MyReviewModel({
    required this.reviewId,
    required this.rating,
    required this.content,
    required this.nickname,
    required this.userId,
    required this.fundingId,
    required this.title,
  });

  factory MyReviewModel.fromJson(Map<String, dynamic> json) {
    return MyReviewModel(
      reviewId: json['reviewId'],
      rating: json['rating'],
      content: json['content'],
      nickname: json['nickname'],
      userId: json['userId'],
      fundingId: json['fundingId'],
      title: json['title'],
    );
  }
}
