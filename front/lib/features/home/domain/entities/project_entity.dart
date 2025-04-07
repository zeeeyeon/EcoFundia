import 'package:equatable/equatable.dart';
import 'package:front/features/home/data/models/project_dto.dart';
import 'package:intl/intl.dart';
import 'package:front/core/services/api_service.dart';

class ProjectEntity extends Equatable {
  final int id;
  final int sellerId;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> imageUrls;
  final double percentage;
  final String price;
  final int priceValue;
  final DateTime endDate;
  final String status;
  final String category;
  final bool isLiked;
  final String sellerName;
  final String? sellerProfileImageUrl;
  final String? storyFileUrl;
  final String? sellerImageUrl;
  final String? sellerDescription;
  final String? location;
  final String? sellerInfoUrl;

  const ProjectEntity({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.imageUrls,
    required this.percentage,
    required this.price,
    required this.priceValue,
    required this.endDate,
    required this.status,
    required this.category,
    this.isLiked = false,
    required this.sellerName,
    this.sellerProfileImageUrl,
    this.storyFileUrl,
    this.sellerImageUrl,
    this.sellerDescription,
    this.location,
    this.sellerInfoUrl,
  });

  @override
  List<Object?> get props => [
        id,
        sellerId,
        title,
        description,
        imageUrl,
        imageUrls,
        percentage,
        price,
        priceValue,
        endDate,
        status,
        category,
        isLiked,
        sellerName,
        sellerProfileImageUrl,
        storyFileUrl,
        sellerImageUrl,
        sellerDescription,
        location,
        sellerInfoUrl,
      ];

  // JSON에서 직접 변환
  factory ProjectEntity.fromJson(Map<String, dynamic> json) {
    final priceValue = json['price'] as int;
    final priceFormatted = NumberFormat('#,##0원').format(priceValue);

    // 이미지 URL 목록 처리
    final List<String> rawImageUrls =
        (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList();

    // 이미지 URL 처리 - 원본 URL 그대로 사용
    final List<String> processedImageUrls =
        rawImageUrls.map((url) => getProxiedImageUrl(url)).toList();

    String mainImageUrl = 'assets/images/test01.png';
    if (processedImageUrls.isNotEmpty) {
      mainImageUrl = processedImageUrls[0];
    }

    return ProjectEntity(
      id: json['fundingId'] as int,
      sellerId: json['sellerId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: mainImageUrl,
      imageUrls: processedImageUrls,
      percentage: (json['rate'] as num).toDouble(),
      price: priceFormatted,
      priceValue: priceValue,
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      category: json['category'] as String,
      isLiked: json['isLiked'] as bool? ?? false,
      sellerName: json['sellerName'] as String? ?? '판매자 정보 없음',
      sellerProfileImageUrl: json['sellerProfileImageUrl'] as String?,
      storyFileUrl: json['storyFileUrl'] != null
          ? getProxiedImageUrl(
              json['storyFileUrl'] as String,
              maxWidth: 1024,
              maxHeight: 2048,
            )
          : null,
      sellerImageUrl: json['sellerImageUrl'] as String?,
      sellerDescription: json['sellerDescription'] as String?,
      location: json['location'] as String?,
      sellerInfoUrl: json['sellerInfoUrl'] as String?,
    );
  }

  factory ProjectEntity.fromDTO(ProjectDTO dto) {
    final priceFormatted = NumberFormat('#,##0원').format(dto.price);

    // 이미지 URL 처리 - 원본 URL 그대로 사용
    final List<String> processedImageUrls =
        dto.imageUrls.map((url) => getProxiedImageUrl(url)).toList();

    String mainImageUrl = 'assets/images/test01.png';
    if (processedImageUrls.isNotEmpty) {
      mainImageUrl = processedImageUrls[0];
    }

    // storyFileUrl 처리 로직 개선
    String? processedStoryFileUrl;
    if (dto.storyFileUrl != null && dto.storyFileUrl!.isNotEmpty) {
      try {
        // 스토리 URL이 있는지 확인하고 로깅
        print('원본 스토리 이미지 URL: ${dto.storyFileUrl}');

        // storyFileUrl은 보통 큰 이미지이므로 WebGL 제한을 고려하여 크기 제한 적용
        processedStoryFileUrl = getProxiedImageUrl(
          dto.storyFileUrl!,
          maxWidth: 1024, // WebGL에서 안전한 크기
          maxHeight: 2048, // WebGL에서 안전한 크기
        );
        print('처리된 스토리 이미지 URL: $processedStoryFileUrl');
      } catch (e) {
        print('스토리 이미지 URL 처리 중 오류: $e');
        // 오류 발생시 원본 URL 그대로 사용
        processedStoryFileUrl = dto.storyFileUrl;
        print('오류로 인해 원본 URL 사용: $processedStoryFileUrl');
      }
    } else {
      print('스토리 이미지 URL이 없거나 비어 있음: ${dto.storyFileUrl}');
    }

    return ProjectEntity(
      id: dto.fundingId,
      sellerId: dto.sellerId,
      title: dto.title,
      description: dto.description,
      imageUrl: mainImageUrl,
      imageUrls: processedImageUrls,
      percentage: dto.rate,
      price: priceFormatted,
      priceValue: dto.price,
      endDate: DateTime.parse(dto.endDate),
      status: dto.status,
      category: dto.category,
      isLiked: dto.isLiked,
      sellerName: dto.sellerName,
      sellerProfileImageUrl: dto.sellerProfileImageUrl,
      storyFileUrl: processedStoryFileUrl,
      sellerImageUrl: dto.sellerImageUrl,
      sellerDescription: dto.sellerDescription,
      location: dto.location,
      sellerInfoUrl: dto.sellerInfoUrl,
    );
  }

  // 객체 복사본 생성 (상태 업데이트용)
  ProjectEntity copyWith({
    int? id,
    int? sellerId,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? imageUrls,
    double? percentage,
    String? price,
    int? priceValue,
    DateTime? endDate,
    String? status,
    String? category,
    bool? isLiked,
    String? sellerName,
    String? sellerProfileImageUrl,
    String? storyFileUrl,
    String? sellerImageUrl,
    String? sellerDescription,
    String? location,
    String? sellerInfoUrl,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      percentage: percentage ?? this.percentage,
      price: price ?? this.price,
      priceValue: priceValue ?? this.priceValue,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      category: category ?? this.category,
      isLiked: isLiked ?? this.isLiked,
      sellerName: sellerName ?? this.sellerName,
      sellerProfileImageUrl:
          sellerProfileImageUrl ?? this.sellerProfileImageUrl,
      storyFileUrl: storyFileUrl ?? this.storyFileUrl,
      sellerImageUrl: sellerImageUrl ?? this.sellerImageUrl,
      sellerDescription: sellerDescription ?? this.sellerDescription,
      location: location ?? this.location,
      sellerInfoUrl: sellerInfoUrl ?? this.sellerInfoUrl,
    );
  }
}
