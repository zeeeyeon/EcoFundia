import 'package:equatable/equatable.dart';
import 'package:front/features/auth/data/models/user_model.dart';
import 'package:front/features/auth/domain/entities/auth_result_entity.dart';

/// 백엔드 응답의 status 부분 모델
class StatusModel extends Equatable {
  final String code;
  final String message;

  const StatusModel({
    required this.code,
    required this.message,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
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
class AuthResponseModel extends Equatable {
  final StatusModel status;
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;
  final String? role;

  const AuthResponseModel({
    required this.status,
    this.accessToken,
    this.refreshToken,
    this.user,
    this.role,
  });

  /// JSON으로부터 객체 생성
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final statusJson = json['status'] as Map<String, dynamic>;
    final content = json['content'] as Map<String, dynamic>?;

    return AuthResponseModel(
      status: StatusModel.fromJson(statusJson),
      accessToken: content != null ? content['accessToken'] as String? : null,
      refreshToken: content != null ? content['refreshToken'] as String? : null,
      user: content != null && content['user'] != null
          ? UserModel.fromJson(content['user'] as Map<String, dynamic>)
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

  /// 도메인 엔티티로 변환
  /// 성공 케이스에서만 호출되어야 함 (모든 필드가 null이 아닌 경우)
  AuthResultEntity toEntity() {
    if (accessToken != null && refreshToken != null && user != null) {
      return AuthResultEntity.success(
        accessToken: accessToken!,
        refreshToken: refreshToken!,
        user: user!.toEntity(),
        role: role,
      );
    } else {
      // 필수 값이 없는 경우 에러로 처리
      return const AuthResultEntity.error(
        '인증 응답이 올바르지 않습니다: 필수 값이 누락되었습니다.',
      );
    }
  }

  @override
  List<Object?> get props => [status, accessToken, refreshToken, user, role];
}
