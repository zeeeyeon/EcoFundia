import 'package:equatable/equatable.dart';
import 'package:front/features/home/data/models/project_dto.dart';

class ProjectEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double percentage;
  final String price;
  final String remainingTime;
  final bool isLiked;

  const ProjectEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.percentage,
    required this.price,
    required this.remainingTime,
    this.isLiked = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        percentage,
        price,
        remainingTime,
        isLiked
      ];

  // JSON에서 직접 변환 (Freezed 사용하지 않음)
  factory ProjectEntity.fromJson(Map<String, dynamic> json) {
    return ProjectEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      percentage: (json['percentage'] as num).toDouble(),
      price: json['price'] as String,
      remainingTime: json['remainingTime'] as String,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  factory ProjectEntity.fromDTO(ProjectDTO dto) {
    return ProjectEntity(
      id: dto.id,
      title: dto.title,
      description: dto.description,
      imageUrl: dto.imageUrl,
      percentage: dto.percentage,
      price: dto.price,
      remainingTime: dto.remainingTime,
      isLiked: dto.isLiked,
    );
  }

  // 객체 복사본 생성 (상태 업데이트용)
  ProjectEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    double? percentage,
    String? price,
    String? remainingTime,
    bool? isLiked,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      percentage: percentage ?? this.percentage,
      price: price ?? this.price,
      remainingTime: remainingTime ?? this.remainingTime,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
