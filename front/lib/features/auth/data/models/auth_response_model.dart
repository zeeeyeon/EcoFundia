import 'package:equatable/equatable.dart';
import 'package:front/features/auth/data/models/user_model.dart';
import 'package:front/features/auth/domain/entities/auth_result_entity.dart';

/// 백엔드 응답의 status 부분 모델
class StatusModel extends Equatable {
  final int code;
  final String message;

  const StatusModel({
    required this.code,
    required this.message,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      code: json['code'] as int,
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
  AuthResultEntity toEntity() {
    // 로그인 성공 (200) 또는 회원가입 성공 (201)
    if ((status.code == 200 || status.code == 201) &&
        accessToken != null &&
        refreshToken != null &&
        user != null) {
      return AuthResultEntity.success(
        accessToken: accessToken!,
        refreshToken: refreshToken!,
        user: user!.toEntity(),
        role: role,
      );
    }
    // 회원가입 필요 (404)
    else if (status.code == 404 &&
        status.message == "해당 이메일로 가입된 사용자가 없습니다. 회원가입이 필요합니다.") {
      // token은 외부에서 주입해야 함
      return const AuthResultEntity.error(
        "해당 이메일로 가입된 사용자가 없습니다. 회원가입이 필요합니다.",
        statusCode: 404,
      );
    }
    // 기타 에러
    else {
      return AuthResultEntity.error(
        status.message,
        statusCode: status.code,
      );
    }
  }

  @override
  List<Object?> get props => [status, accessToken, refreshToken, user, role];
}
