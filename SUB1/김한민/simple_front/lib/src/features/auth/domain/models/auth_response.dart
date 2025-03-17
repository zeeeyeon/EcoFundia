import 'package:equatable/equatable.dart';

/// 서버로부터 받는 인증 응답 모델
class AuthResponse extends Equatable {
  final String? token;
  final String? refreshToken;
  final bool isNewUser;
  final String? message;
  final String? userId;

  const AuthResponse({
    this.token,
    this.refreshToken,
    required this.isNewUser,
    this.message,
    this.userId,
  });

  /// JSON으로부터 객체 생성
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      isNewUser: json['isNewUser'] as bool? ?? false,
      message: json['message'] as String?,
      userId: json['userId'] as String?,
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() => {
        'token': token,
        'refreshToken': refreshToken,
        'isNewUser': isNewUser,
        'message': message,
        'userId': userId,
      };

  @override
  List<Object?> get props => [token, refreshToken, isNewUser, message, userId];
}
