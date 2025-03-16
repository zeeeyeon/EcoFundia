class AuthState {
  final bool isAuthenticated;
  final String? authCode;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.authCode,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? authCode,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      authCode: authCode ?? this.authCode,
      error: error ?? this.error,
    );
  }
}
