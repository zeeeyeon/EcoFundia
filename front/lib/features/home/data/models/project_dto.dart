import 'package:equatable/equatable.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';

class ProjectDTO extends Equatable {
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
  final String startDate;
  final String endDate;
  final String status;
  final String category;
  final double rate;
  final bool isLiked;
  final String sellerName;
  final String? sellerProfileImageUrl;
  final String? sellerImageUrl;
  final String? sellerDescription;
  final String? location;
  final String? sellerInfoUrl;

  const ProjectDTO({
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
    this.isLiked = false,
    required this.sellerName,
    this.sellerProfileImageUrl,
    this.sellerImageUrl,
    this.sellerDescription,
    this.location,
    this.sellerInfoUrl,
  });

  @override
  List<Object?> get props => [
        fundingId,
        sellerId,
        title,
        description,
        storyFileUrl,
        imageUrls,
        price,
        quantity,
        targetAmount,
        currentAmount,
        startDate,
        endDate,
        status,
        category,
        rate,
        isLiked,
        sellerName,
        sellerProfileImageUrl,
        sellerImageUrl,
        sellerDescription,
        location,
        sellerInfoUrl,
      ];

  // API 응답에서 DTO 생성
  factory ProjectDTO.fromJson(Map<String, dynamic> json) {
    return ProjectDTO(
      fundingId: json['fundingId'] as int,
      sellerId: json['sellerId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      storyFileUrl: json['storyFileUrl'] as String,
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      price: json['price'] as int,
      quantity: json['quantity'] as int,
      targetAmount: json['targetAmount'] as int,
      currentAmount: json['currentAmount'] as int,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      status: json['status'] as String,
      category: json['category'] as String,
      rate: (json['rate'] as num).toDouble(),
      isLiked: json['isLiked'] as bool? ?? false,
      sellerName: json['sellerName'] as String? ?? '판매자 정보 없음',
      sellerProfileImageUrl: json['sellerProfileImageUrl'] as String?,
      sellerImageUrl: json['sellerImageUrl'] as String?,
      sellerDescription: json['sellerDescription'] as String?,
      location: json['location'] as String?,
      sellerInfoUrl: json['sellerInfoUrl'] as String?,
    );
  }

  // DTO를 Domain Entity로 변환
  ProjectEntity toEntity() {
    return ProjectEntity.fromDTO(this);
  }

  Map<String, dynamic> toJson() {
    return {
      'fundingId': fundingId,
      'sellerId': sellerId,
      'title': title,
      'description': description,
      'storyFileUrl': storyFileUrl,
      'imageUrls': imageUrls,
      'price': price,
      'quantity': quantity,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'category': category,
      'rate': rate,
      'isLiked': isLiked,
      'sellerName': sellerName,
      'sellerProfileImageUrl': sellerProfileImageUrl,
      'sellerImageUrl': sellerImageUrl,
      'sellerDescription': sellerDescription,
      'location': location,
      'sellerInfoUrl': sellerInfoUrl,
    };
  }
}
