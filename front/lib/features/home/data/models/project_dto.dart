import 'package:equatable/equatable.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';

class ProjectDTO extends Equatable {
  final int fundingId;
  final int sellerId;
  final String title;
  final String description;
  final String? storyFileUrl;
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
    this.storyFileUrl,
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

  // 이미지 URL 유효성 검증
  static String? _validateImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    // 이미지 파일 확장자 확인
    final validExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.bmp',
      '.svg'
    ];
    final lowercaseUrl = url.toLowerCase();

    // 이미지 파일 형식인지 확인
    bool hasValidExtension =
        validExtensions.any((ext) => lowercaseUrl.endsWith(ext));

    // 특정 도메인 필터링 (이미지가 아닌 URL 제외)
    bool hasInvalidDomain = lowercaseUrl.contains('meeting.ssafy.com');

    // 유효한 URL인지 확인
    bool isValidUrlFormat = url.startsWith('http') ||
        url.contains('s3.') ||
        url.contains('amazonaws.com');

    if (isValidUrlFormat && hasValidExtension && !hasInvalidDomain) {
      return url;
    }

    return null;
  }

  // API 응답에서 DTO 생성
  factory ProjectDTO.fromJson(Map<String, dynamic> json) {
    // 판매자 이미지 URL 검증
    final String? rawSellerImageUrl = json['sellerImageUrl'] as String?;
    final String? rawSellerProfileImageUrl =
        json['sellerProfileImageUrl'] as String?;

    // 둘 다 null이 아닌 경우 유효성 검증
    String? validSellerImageUrl = _validateImageUrl(rawSellerImageUrl);
    String? validSellerProfileImageUrl =
        _validateImageUrl(rawSellerProfileImageUrl);

    // sellerImageUrl이 없고 sellerProfileImageUrl이 유효하면 대체
    if (validSellerImageUrl == null && validSellerProfileImageUrl != null) {
      validSellerImageUrl = validSellerProfileImageUrl;
    }

    // sellerProfileImageUrl이 없고 sellerImageUrl이 유효하면 대체
    if (validSellerProfileImageUrl == null && validSellerImageUrl != null) {
      validSellerProfileImageUrl = validSellerImageUrl;
    }

    return ProjectDTO(
      fundingId: json['fundingId'] as int,
      sellerId: json['sellerId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      storyFileUrl: json['storyFileUrl'] as String?,
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
      sellerProfileImageUrl: validSellerProfileImageUrl,
      sellerImageUrl: validSellerImageUrl,
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
