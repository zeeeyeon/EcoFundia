class GoogleSignInResult {
  final String accessToken;
  final String? serverAuthCode; // 모바일에서만 사용됨
  final String? email;
  final String? name;

  GoogleSignInResult({
    required this.accessToken,
    this.serverAuthCode,
    this.email,
    this.name,
  });
}
