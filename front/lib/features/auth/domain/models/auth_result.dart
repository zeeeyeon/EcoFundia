import 'package:equatable/equatable.dart';
import 'package:front/features/auth/domain/models/auth_response.dart';

sealed class AuthResult extends Equatable {
  const AuthResult();

  @override
  List<Object?> get props => [];

  const factory AuthResult.success(AuthResponse response) = AuthSuccess;
  const factory AuthResult.error(String message, {int? statusCode}) = AuthError;
  const factory AuthResult.cancelled() = AuthCancelled;
  const factory AuthResult.newUser(String message) = AuthNewUser;
}

class AuthSuccess extends AuthResult {
  final AuthResponse response;

  const AuthSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class AuthError extends AuthResult {
  final String message;
  final int? statusCode;

  const AuthError(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class AuthCancelled extends AuthResult {
  const AuthCancelled();
}

class AuthNewUser extends AuthResult {
  final String message;

  const AuthNewUser(this.message);

  @override
  List<Object?> get props => [message];
}
