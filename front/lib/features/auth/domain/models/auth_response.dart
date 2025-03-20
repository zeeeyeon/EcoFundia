import 'package:equatable/equatable.dart';

/// 백엔드 응답의 status 부분 모델 (선택적으로 사용)
class Status extends Equatable {
  final String code;
  final String message;

  const Status({
    required this.code,
    required this.message,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      code: json['code'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
      };

  @override
  List<Object?> get props => [code, message];
}

/// 서버로부터 받는 인증 응답 모델
class AuthResponse extends Equatable {
  final Status status;
  final String? accessToken;
  final String? refreshToken;
  final UserInfo? user;
  final String? role;

  const AuthResponse({
    required this.status,
    this.accessToken,
    this.refreshToken,
    this.user,
    this.role,
  });

  /// JSON으로부터 객체 생성 (새로운 응답 구조에 맞게 수정)
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final statusJson = json['status'] as Map<String, dynamic>;
    final content = json['content'] as Map<String, dynamic>?;

    return AuthResponse(
      status: Status.fromJson(statusJson),
      accessToken: content != null ? content['accessToken'] as String? : null,
      refreshToken: content != null ? content['refreshToken'] as String? : null,
      user: content != null && content['user'] != null
          ? UserInfo.fromJson(content['user'] as Map<String, dynamic>)
          : null,
      role: content != null ? content['role'] as String? : null,
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() => {
        'status': status.toJson(),
        'content': {
          'accessToken': accessToken,
          'refreshToken': refreshToken,
          'user': user?.toJson(),
          'role': role,
        },
      };

  @override
  List<Object?> get props => [status, accessToken, refreshToken, user, role];
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
