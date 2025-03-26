class FundingModel {
  final int fundingId;
  final int sellerId;
  final String title;
  final String description;
  final String storyFileUrl;
  final List<String> imageUrls;
  final int price;
  final int quantity;
  final int targetAmount;
  final int currentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String category;
  final int rate;

  FundingModel({
    required this.fundingId,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.storyFileUrl,
    required this.imageUrls,
    required this.price,
    required this.quantity,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.category,
    required this.rate,
  });

  factory FundingModel.fromJson(Map<String, dynamic> json) {
    return FundingModel(
      fundingId: json['fundingId'],
      sellerId: json['sellerId'],
      title: json['title'],
      description: json['description'],
      storyFileUrl: json['storyFileUrl'],
      imageUrls: List<String>.from(json['imageUrls']),
      price: json['price'],
      quantity: json['quantity'],
      targetAmount: json['targetAmount'],
      currentAmount: json['currentAmount'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'],
      category: json['category'],
      rate: json['rate'],
    );
  }
}
