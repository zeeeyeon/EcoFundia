import 'package:equatable/equatable.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';

class ProjectDTO extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double percentage;
  final String price;
  final String remainingTime;
  final bool isLiked;

  const ProjectDTO({
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

  // API 응답에서 DTO 생성
  factory ProjectDTO.fromJson(Map<String, dynamic> json) {
    return ProjectDTO(
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

  // DTO를 Domain Entity로 변환
  ProjectEntity toEntity() {
    return ProjectEntity(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      percentage: percentage,
      price: price,
      remainingTime: remainingTime,
      isLiked: isLiked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'percentage': percentage,
      'price': price,
      'remainingTime': remainingTime,
      'isLiked': isLiked,
    };
  }
}
