import 'package:equatable/equatable.dart';

/// 인증 상태 클래스
class AuthState extends Equatable {
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;
  final bool isNewUser;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.error,
    this.isNewUser = false,
  });

  /// 초기 상태
  factory AuthState.initial() {
    return const AuthState();
  }

  /// 로딩 상태
  AuthState copyWithLoading() {
    return const AuthState(isLoading: true);
  }

  /// 상태 복사본 생성
  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? error,
    bool? isNewUser,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  @override
  List<Object?> get props => [isLoggedIn, isLoading, error, isNewUser];
}
