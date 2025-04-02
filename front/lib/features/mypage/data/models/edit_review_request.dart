class EditReviewRequest {
  final int rating;
  final String content;

  EditReviewRequest({
    required this.rating,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'content': content,
      };
}
