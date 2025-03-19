import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

// 로그 레벨 정의
enum LogLevel {
  verbose, // 모든 로그 출력
  debug, // 디버그 이상 출력
  info, // 정보 이상 출력
  warning, // 경고 이상 출력
  error, // 에러만 출력
  nothing, // 로그 출력 없음
}

/// 앱 전체에서 사용할 로거 유틸리티
class LoggerUtil {
  // 로그 출력 수준 설정
  static LogLevel _logLevel = kDebugMode ? LogLevel.debug : LogLevel.error;

  // 현재 로그 수준 설정
  static void setLogLevel(LogLevel level) {
    _logLevel = level;
  }

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1, // 호출 스택에 표시할 메서드 수를 줄임
      errorMethodCount: 5, // 에러 발생 시 표시할 메서드 수
      lineLength: 120, // 출력 라인 최대 길이
      colors: true, // 컬러 출력 활성화
      printEmojis: true, // 이모지 출력 활성화
      printTime: true, // 시간 출력 활성화
    ),
    level: Level.info, // 기본 로그 레벨을 info로 설정하여 debug 메시지를 감춤
  );

  // 일반 디버그 로그
  static void d(String message) {
    if (_logLevel.index <= LogLevel.debug.index) {
      _logger.d(message);
    }
  }

  // 정보 로그
  static void i(String message) {
    if (_logLevel.index <= LogLevel.info.index) {
      _logger.i(message);
    }
  }

  // 경고 로그
  static void w(String message) {
    if (_logLevel.index <= LogLevel.warning.index) {
      _logger.w(message);
    }
  }

  // 에러 로그
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_logLevel.index <= LogLevel.error.index) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  // 안전한 문자열 길이 제한
  static String truncate(String? text, int maxLength) {
    if (text == null) return "null";
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // 토큰이나 인증 코드 안전하게 로깅 (일부 가리기)
  static String safeToken(String? token) {
    if (token == null) return "null";
    if (token.length <= 8) return "***";

    // 처음 4자와 마지막 4자만 표시, 나머지는 *로 대체
    final start = token.substring(0, 4);
    final end = token.substring(token.length - 4);
    final masked = '*' * (token.length - 8);

    return '$start$masked$end';
  }

  // 인증 정보 안전하게 로깅
  static void logAuthInfo(Map<String, dynamic> authInfo) {
    if (_logLevel.index > LogLevel.debug.index) return; // debug 레벨 이하에서만 로깅

    final sanitizedInfo = Map<String, dynamic>.from(authInfo);

    // 민감한 정보 마스킹
    if (sanitizedInfo.containsKey('accessToken')) {
      sanitizedInfo['accessToken'] = safeToken(sanitizedInfo['accessToken']);
    }
    if (sanitizedInfo.containsKey('idToken')) {
      sanitizedInfo['idToken'] = safeToken(sanitizedInfo['idToken']);
    }
    if (sanitizedInfo.containsKey('serverAuthCode')) {
      sanitizedInfo['serverAuthCode'] =
          safeToken(sanitizedInfo['serverAuthCode']);
    }

    _logger.i('📦 인증 정보: $sanitizedInfo');
  }
}
