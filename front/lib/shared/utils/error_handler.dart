import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/shared/widgets/error_dialog.dart';

// Mixin에 정의된 예외 클래스들을 여기로 가져옴
// TODO: 이 예외 클래스들을 별도의 파일 (예: lib/core/errors/exceptions.dart)로 분리하는 것을 고려

/// 네트워크 오류 예외 기본 클래스
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetwork;

  NetworkException(this.message, {this.statusCode, this.isNetwork = true});

  @override
  String toString() => message;
}

/// 쿠폰 관련 오류 예외 클래스
class CouponException implements Exception {
  final String message;
  final int? statusCode;
  final CouponErrorType type;

  CouponException(this.message,
      {this.statusCode, this.type = CouponErrorType.unknown});

  @override
  String toString() => message;
}

/// 쿠폰 오류 타입
enum CouponErrorType {
  unknown,
  alreadyIssued,
  notAvailable,
  expired,
  invalid,
  serverError,
  networkError,
  unauthorized,
  // CouponService의 CouponApplyResult와 통합 필요 가능성 있음
  timeLimit, // 시간 제한 추가 (CouponApplyResult의 CouponTimeLimitFailure)
}

/// 인증 관련 오류 예외 클래스
class AuthException implements Exception {
  final String message;
  final int? statusCode;
  final AuthErrorType type;

  AuthException(this.message,
      {this.statusCode, this.type = AuthErrorType.unknown});

  @override
  String toString() => message;
}

/// 인증 오류 타입
enum AuthErrorType {
  unknown,
  invalidCredentials,
  tokenExpired,
  tokenInvalid,
  unauthorized,
  serverError,
  networkError,
  userNotFound,
  emailAlreadyInUse,
}

/// 중앙 집중식 오류 처리 유틸리티
class ErrorHandler {
  /// 발생한 오류를 처리하고 사용자에게 알림 (에러 다이얼로그 표시)
  ///
  /// [context]: 다이얼로그를 표시하기 위한 BuildContext
  /// [error]: 처리할 오류 객체 (Exception, DioException 등)
  /// [title]: 다이얼로그 제목 (기본값: '오류 발생')
  /// [operationDescription]: 오류 발생 상황 설명 (로그용, 선택 사항)
  /// [onConfirm]: 다이얼로그 확인 버튼 콜백 (선택 사항)
  static Future<void> handleError(
    BuildContext context,
    dynamic error, {
    String title = '오류 발생',
    String? operationDescription,
    VoidCallback? onConfirm,
  }) async {
    // 1. 오류 로깅
    if (operationDescription != null) {
      LoggerUtil.e('$operationDescription 중 오류 발생', error);
    } else {
      LoggerUtil.e('오류 발생', error);
    }

    // 2. 사용자 친화적 메시지 생성
    final message = getUserFriendlyMessage(error);

    // 3. 에러 다이얼로그 표시
    // context가 유효한 경우 (마운트된 상태)에만 다이얼로그 표시
    if (context.mounted) {
      await ErrorDialog.show(
        context,
        title: title,
        message: message,
        onConfirm: onConfirm,
      );
    }
  }

  /// 오류 객체로부터 사용자 친화적인 메시지 문자열 생성
  static String getUserFriendlyMessage(dynamic error) {
    if (error is DioException) {
      return _getDioErrorMessage(error);
    } else if (error is NetworkException) {
      return _getNetworkErrorMessage(error);
    } else if (error is CouponException) {
      return _getCouponErrorMessage(error);
    } else if (error is AuthException) {
      return _getAuthErrorMessage(error);
    } else if (error is String) {
      // 문자열로 오류 메시지가 직접 전달된 경우
      return error.isNotEmpty ? error : '알 수 없는 오류가 발생했습니다.';
    } else {
      // 기타 예외 처리
      LoggerUtil.w('처리되지 않은 예외 타입: ${error.runtimeType}, 오류: $error');
      return '알 수 없는 오류가 발생했습니다. 다시 시도해 주세요.';
    }
  }

  /// Dio 오류에 대한 사용자 친화적인 메시지 생성 (내부 헬퍼)
  static String _getDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '서버 응답이 너무 늦습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        // 특정 상태 코드에 대한 메시지 분기
        if (statusCode == 400) {
          // 400 에러는 좀 더 구체적인 정보가 있을 수 있음 (예: 쿠폰 관련)
          // 백엔드 응답에 메시지가 포함되어 있다면 사용
          final responseData = error.response?.data;
          if (responseData is Map && responseData.containsKey('message')) {
            return responseData['message'];
          } else {
            return '잘못된 요청입니다. 입력 내용을 확인해 주세요.';
          }
        }
        if (statusCode == 401 || statusCode == 403) {
          return '접근 권한이 없습니다. 로그인이 필요하거나 권한이 부족합니다.';
        }
        if (statusCode == 404) {
          return '요청한 정보를 찾을 수 없습니다. 잠시 후 다시 시도해 주세요.';
        }
        if (statusCode == 500) {
          return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.';
        }
        if (statusCode == 503) {
          return '서비스가 일시적으로 사용 불가능합니다. 잠시 후 다시 시도해 주세요.';
        }
        // 기타 상태 코드
        return '서버 응답 오류 (코드: ${statusCode ?? '알 수 없음'}). 다시 시도해 주세요.';
      case DioExceptionType.cancel:
        return '요청이 취소되었습니다. 다시 시도해 주세요.';
      case DioExceptionType.connectionError:
        return '네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
      case DioExceptionType.unknown:
      default:
        return '알 수 없는 오류가 발생했습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
    }
  }

  /// 네트워크 오류에 대한 사용자 친화적인 메시지 생성 (내부 헬퍼)
  static String _getNetworkErrorMessage(NetworkException error) {
    final statusCode = error.statusCode;

    if (statusCode == null) {
      return '네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
    }

    // 상태 코드별 맞춤 메시지
    switch (statusCode) {
      case 0: // 연결 실패 (DioExceptionType.connectionError와 유사)
        return '서버에 연결할 수 없습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
      case 404:
        return '요청한 정보를 찾을 수 없습니다. 잠시 후 다시 시도해 주세요.';
      case 408: // 요청 시간 초과
        return '서버 응답 시간이 초과되었습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
      case 500:
        return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      case 502: // Bad Gateway
      case 503: // Service Unavailable
      case 504: // Gateway Timeout
        return '서비스가 일시적으로 사용 불가능합니다. 잠시 후 다시 시도해 주세요.';
      default:
        return error.message; // NetworkException 생성 시 전달된 메시지 사용
    }
  }

  /// 쿠폰 오류에 대한 사용자 친화적인 메시지 생성 (내부 헬퍼)
  static String _getCouponErrorMessage(CouponException error) {
    switch (error.type) {
      case CouponErrorType.alreadyIssued:
        return '이미 발급받은 쿠폰입니다.';
      case CouponErrorType.notAvailable:
        return '현재 사용할 수 없는 쿠폰입니다.';
      case CouponErrorType.expired:
        return '만료된 쿠폰입니다.';
      case CouponErrorType.invalid:
        return '유효하지 않은 쿠폰입니다.';
      case CouponErrorType.serverError:
        return '쿠폰 처리 중 서버 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      case CouponErrorType.networkError:
        return '쿠폰 처리 중 네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
      case CouponErrorType.unauthorized:
        return '쿠폰 관련 작업을 위해 로그인이 필요합니다.';
      case CouponErrorType.timeLimit:
        return error
            .message; // CouponException 생성 시 전달된 메시지 사용 (예: "쿠폰 발급은 오전 10시부터 가능합니다.")
      case CouponErrorType.unknown:
      default:
        // CouponException 생성 시 전달된 구체적인 메시지가 있다면 사용
        return error.message.isNotEmpty
            ? error.message
            : '쿠폰 관련 알 수 없는 오류가 발생했습니다.';
    }
  }

  /// 인증 오류에 대한 사용자 친화적인 메시지 생성 (내부 헬퍼)
  static String _getAuthErrorMessage(AuthException error) {
    switch (error.type) {
      case AuthErrorType.invalidCredentials:
        return '아이디 또는 비밀번호가 올바르지 않습니다.';
      case AuthErrorType.tokenExpired:
        return '로그인 세션이 만료되었습니다. 다시 로그인해 주세요.';
      case AuthErrorType.tokenInvalid:
        return '유효하지 않은 인증 정보입니다. 다시 로그인해 주세요.';
      case AuthErrorType.unauthorized:
        return '접근 권한이 없습니다. 로그인이 필요하거나 권한이 부족합니다.';
      case AuthErrorType.serverError:
        return '인증 처리 중 서버 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      case AuthErrorType.networkError:
        return '인증 처리 중 네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
      case AuthErrorType.userNotFound:
        return '사용자 정보를 찾을 수 없습니다.';
      case AuthErrorType.emailAlreadyInUse:
        return '이미 사용 중인 이메일입니다.';
      case AuthErrorType.unknown:
      default:
        // AuthException 생성 시 전달된 구체적인 메시지가 있다면 사용
        return error.message.isNotEmpty
            ? error.message
            : '인증 관련 알 수 없는 오류가 발생했습니다.';
    }
  }
}
