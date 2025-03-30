class FundingDetailModel {
  final FundingInfo fundingInfo;
  final SellerInfo sellerInfo;

  FundingDetailModel({
    required this.fundingInfo,
    required this.sellerInfo,
  });

  factory FundingDetailModel.fromJson(Map<String, dynamic> json) {
    return FundingDetailModel(
      fundingInfo: FundingInfo.fromJson(json['fundingInfo']),
      sellerInfo: SellerInfo.fromJson(json['sellerInfo']),
    );
  }
}

class FundingInfo {
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

  FundingInfo({
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

  factory FundingInfo.fromJson(Map<String, dynamic> json) {
    return FundingInfo(
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

class SellerInfo {
  final int sellerId;
  final String sellerName;
  final String sellerProfileImageUrl;

  SellerInfo({
    required this.sellerId,
    required this.sellerName,
    required this.sellerProfileImageUrl,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      sellerId: json['sellerId'],
      sellerName: json['sellerName'],
      sellerProfileImageUrl: json['sellerProfileImageUrl'] ?? '',
    );
  }
}
