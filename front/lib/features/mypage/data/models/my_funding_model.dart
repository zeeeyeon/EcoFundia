class MyFundingModel {
  final int fundingId;
  final String title;
  final String description;
  final List<String> imageUrls;
  final DateTime endDate;
  final int currentAmount;
  final String category;
  final String status;
  final int rate;
  final int totalPrice;

  MyFundingModel({
    required this.fundingId,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.endDate,
    required this.currentAmount,
    required this.category,
    required this.status,
    required this.rate,
    required this.totalPrice,
  });

  factory MyFundingModel.fromJson(Map<String, dynamic> json) {
    final imageListString = json['imageUrl'] as String;
    final decodedImageList = imageListString
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .split(',')
        .map((e) => e.trim())
        .toList();

    return MyFundingModel(
      fundingId: json['fundingId'],
      title: json['title'],
      description: json['description'],
      imageUrls: decodedImageList,
      endDate: DateTime.parse(json['endDate']),
      currentAmount: json['currentAmount'],
      category: json['category'],
      status: json['status'],
      rate: json['rate'],
      totalPrice: json['totalPrice'],
    );
  }
}
