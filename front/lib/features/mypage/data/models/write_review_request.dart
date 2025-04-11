class WriteReviewRequest {
  final int fundingId;
  final int rating;
  final String content;

  WriteReviewRequest({
    required this.fundingId,
    required this.rating,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'fundingId': fundingId,
      'rating': rating,
      'content': content,
    };
  }
}
