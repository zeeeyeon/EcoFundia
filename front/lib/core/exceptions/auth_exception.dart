/// 인증 관련 예외 클래스
class AuthException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNewUser;

  AuthException(this.message, {this.statusCode, this.isNewUser = false});

  @override
  String toString() => message;
}

/// 유효성 검증 예외
class ValidationException extends AuthException {
  ValidationException(String message) : super(message, statusCode: 400);
}
