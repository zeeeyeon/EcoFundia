import 'package:front/utils/funding_status.dart';
import 'dart:convert'; // ✅ jsonDecode 사용 위해 추가

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
    List<String> imageUrls = [];
    if (json['imageUrl'] is String) {
      try {
        // imageUrl이 문자열이면 jsonDecode 시도
        final decoded = jsonDecode(json['imageUrl']);
        if (decoded is List) {
          imageUrls = List<String>.from(decoded);
        }
      } catch (e) {
        // JSON 파싱 실패 시 빈 리스트 유지
        print('Error decoding imageUrl JSON string: $e');
      }
    } else if (json['imageUrl'] is List) {
      // 이미 리스트 형태이면 그대로 사용
      imageUrls = List<String>.from(json['imageUrl']);
    }

    return MyFundingModel(
      fundingId: json['fundingId'],
      title: json['title'],
      description: json['description'],
      imageUrls: imageUrls, // 수정된 imageUrls 사용
      endDate: DateTime.parse(json['endDate']),
      currentAmount: json['currentAmount'],
      category: json['category'],
      status: parseFundingStatus(json['status']),
      rate: json['rate'],
      totalPrice: json['totalPrice'] ?? 0, // 혹시 없을 수도 있으니 기본값 설정
    );
  }
}
