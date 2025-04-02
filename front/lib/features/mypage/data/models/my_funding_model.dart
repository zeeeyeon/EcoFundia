import 'package:front/utils/funding_status.dart';

class MyFundingModel {
  final int fundingId;
  final String title;
  final String description;
  final List<String> imageUrls;
  final DateTime endDate;
  final int currentAmount;
  final String category;
  final FundingStatus status;
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
    return MyFundingModel(
      fundingId: json['fundingId'],
      title: json['title'],
      description: json['description'],
      imageUrls: List<String>.from(json['imageUrl']), // 바로 List로 파싱
      endDate: DateTime.parse(json['endDate']),
      currentAmount: json['currentAmount'],
      category: json['category'],
      status: parseFundingStatus(json['status']),
      rate: json['rate'],
      totalPrice: json['totalPrice'] ?? 0, // 혹시 없을 수도 있으니 기본값 설정
    );
  }
}
