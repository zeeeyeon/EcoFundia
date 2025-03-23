import 'package:front/features/auth/domain/entities/user_entity.dart';

/// 사용자 정보 API 응답 모델
/// API 응답에서 받은 사용자 데이터를 처리
class UserModel {
  final int userId;
  final String email;
  final String name;
  final String nickname;
  final String gender;
  final int age;
  final DateTime createdAt;

  const UserModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.nickname,
    required this.gender,
    required this.age,
    required this.createdAt,
  });

  /// JSON으로부터 모델 객체 생성
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String,
      gender: json['gender'] as String,
      age: json['age'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'name': name,
        'nickname': nickname,
        'gender': gender,
        'age': age,
        'createdAt': createdAt.toIso8601String(),
      };

  /// 도메인 엔티티로 변환
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      email: email,
      name: name,
      nickname: nickname,
      gender: gender,
      age: age,
      createdAt: createdAt,
    );
  }

  /// 도메인 엔티티로부터 모델 생성
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      userId: entity.userId,
      email: entity.email,
      name: entity.name,
      nickname: entity.nickname,
      gender: entity.gender,
      age: entity.age,
      createdAt: entity.createdAt,
    );
  }
}
