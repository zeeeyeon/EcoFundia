import 'package:equatable/equatable.dart';
import 'package:front/features/auth/domain/entities/user_entity.dart';

/// 인증 결과를 나타내는 엔티티 클래스
/// 다양한 인증 결과 상태(성공, 실패, 취소 등)를 표현
sealed class AuthResultEntity extends Equatable {
  const AuthResultEntity();

  @override
  List<Object?> get props => [];

  const factory AuthResultEntity.success({
    required String accessToken,
    required String refreshToken,
    required UserEntity user,
    String? role,
  }) = AuthSuccessEntity;

  const factory AuthResultEntity.error(String message, {int? statusCode}) =
      AuthErrorEntity;

  const factory AuthResultEntity.cancelled() = AuthCancelledEntity;

  const factory AuthResultEntity.newUser(String message) = AuthNewUserEntity;
}

/// 인증 성공 결과
class AuthSuccessEntity extends AuthResultEntity {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;
  final String? role;

  const AuthSuccessEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.role,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user, role];
}

/// 인증 오류 결과
class AuthErrorEntity extends AuthResultEntity {
  final String message;
  final int? statusCode;

  const AuthErrorEntity(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// 인증 취소 결과
class AuthCancelledEntity extends AuthResultEntity {
  const AuthCancelledEntity();
}

/// 신규 사용자 결과 (회원가입 필요)
class AuthNewUserEntity extends AuthResultEntity {
  final String message;

  const AuthNewUserEntity(this.message);

  @override
  List<Object?> get props => [message];
}
