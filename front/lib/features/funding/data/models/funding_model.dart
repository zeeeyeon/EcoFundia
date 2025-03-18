class FundingModel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final double targetAmount;
  final double currentAmount;

  FundingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.targetAmount,
    required this.currentAmount,
  });

  // JSON 데이터를 Dart 객체로 변환
  factory FundingModel.fromJson(Map<String, dynamic> json) {
    return FundingModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
    );
  }

  // Dart 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
    };
  }
}
