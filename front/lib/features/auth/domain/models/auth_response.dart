import 'package:equatable/equatable.dart';

/// 서버로부터 받는 인증 응답 모델
class AuthResponse extends Equatable {
  final String? accessToken;
  final String? refreshToken;
  final UserInfo? user;
  final String? role;
  final String? message;

  const AuthResponse({
    this.accessToken,
    this.refreshToken,
    this.user,
    this.role,
    this.message,
  });

  /// JSON으로부터 객체 생성
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
      role: json['role'] as String?,
      message: json['message'] as String?,
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'user': user?.toJson(),
        'role': role,
        'message': message,
      };

  @override
  List<Object?> get props => [accessToken, refreshToken, user, role, message];
}

class UserInfo extends Equatable {
  final int userId;
  final String email;
  final String name;
  final String nickname;
  final String gender;
  final int age;
  final DateTime createdAt;

  const UserInfo({
    required this.userId,
    required this.email,
    required this.name,
    required this.nickname,
    required this.gender,
    required this.age,
    required this.createdAt,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String,
      gender: json['gender'] as String,
      age: json['age'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'name': name,
        'nickname': nickname,
        'gender': gender,
        'age': age,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [userId, email, name, nickname, gender, age, createdAt];
}
