import 'package:flutter/foundation.dart';

enum AuthStatus { initial, authenticated, unauthenticated, error }

@immutable
class AuthState {
  final AuthStatus status;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? tokenExpiry;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiry,
    this.error,
  });

  bool get isAuthenticated =>
      status == AuthStatus.authenticated &&
      accessToken != null &&
      (tokenExpiry?.isAfter(DateTime.now()) ?? false);

  AuthState copyWith({
    AuthStatus? status,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiry,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          tokenExpiry == other.tokenExpiry &&
          error == other.error;

  @override
  int get hashCode =>
      status.hashCode ^
      accessToken.hashCode ^
      refreshToken.hashCode ^
      tokenExpiry.hashCode ^
      error.hashCode;
}
