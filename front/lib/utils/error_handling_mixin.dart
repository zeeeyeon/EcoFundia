import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/utils/logger_util.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// 오류 상태 열거형
enum LoadingStateType {
  initial,
  loading,
  loaded,
  error,
  networkError,
}

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

/// ViewModel에서 공통으로 사용하는 오류 처리 기능 (클래스에 상관없이 사용)
class ErrorHandlingUtil {
  /// Dio 오류에 대한 사용자 친화적인 메시지 생성
  static String getDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '서버 응답이 너무 늦습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return '요청한 정보를 찾을 수 없습니다. 잠시 후 다시 시도해 주세요.';
        } else if (statusCode == 500) {
          return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.';
        } else if (statusCode == 503) {
          return '서비스가 일시적으로 사용 불가능합니다. 잠시 후 다시 시도해 주세요.';
        }
        return '서버 응답 오류 (${error.response?.statusCode}). 다시 시도해 주세요.';
      case DioExceptionType.cancel:
        return '요청이 취소되었습니다. 다시 시도해 주세요.';
      case DioExceptionType.connectionError:
        return '네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
      case DioExceptionType.unknown:
      default:
        return '알 수 없는 오류가 발생했습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
    }
  }

  /// 네트워크 오류에 대한 사용자 친화적인 메시지 생성
  static String getNetworkErrorMessage(NetworkException error) {
    final statusCode = error.statusCode;

    if (statusCode == null) {
      return '네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
    }

    // 상태 코드별 맞춤 메시지
    switch (statusCode) {
      case 0: // 연결 실패
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
        return error.message;
    }
  }

  /// 쿠폰 오류에 대한 사용자 친화적인 메시지 생성
  static String getCouponErrorMessage(CouponException error) {
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
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      case CouponErrorType.networkError:
        return '네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
      case CouponErrorType.unauthorized:
        return '로그인이 필요한 서비스입니다.';
      case CouponErrorType.unknown:
      default:
        return error.message;
    }
  }

  /// 인증 오류에 대한 사용자 친화적인 메시지 생성
  static String getAuthErrorMessage(AuthException error) {
    switch (error.type) {
      case AuthErrorType.invalidCredentials:
        return '아이디 또는 비밀번호가 올바르지 않습니다.';
      case AuthErrorType.tokenExpired:
        return '로그인 세션이 만료되었습니다. 다시 로그인해 주세요.';
      case AuthErrorType.tokenInvalid:
        return '유효하지 않은 인증 정보입니다. 다시 로그인해 주세요.';
      case AuthErrorType.unauthorized:
        return '로그인이 필요한 서비스입니다.';
      case AuthErrorType.serverError:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      case AuthErrorType.networkError:
        return '네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
      case AuthErrorType.userNotFound:
        return '사용자를 찾을 수 없습니다.';
      case AuthErrorType.emailAlreadyInUse:
        return '이미 사용 중인 이메일입니다.';
      case AuthErrorType.unknown:
      default:
        return error.message;
    }
  }

  /// 일반 예외에 대한 사용자 친화적인 메시지 생성
  static String getGenericErrorMessage(dynamic error) {
    if (error is DioException) {
      return getDioErrorMessage(error);
    } else if (error is NetworkException) {
      return getNetworkErrorMessage(error);
    } else if (error is CouponException) {
      return getCouponErrorMessage(error);
    } else if (error is AuthException) {
      return getAuthErrorMessage(error);
    } else {
      return '오류가 발생했습니다. 다시 시도해 주세요.';
    }
  }
}

/// ChangeNotifier 기반 ViewModel에서 오류 처리를 위한 Mixin
mixin ChangeNotifierErrorHandlingMixin on ChangeNotifier {
  // 에러 메시지
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // 네트워크 오류 여부
  bool _isNetworkError = false;
  bool get isNetworkError => _isNetworkError;

  // 오류 코드
  int? _lastErrorCode;
  int? get lastErrorCode => _lastErrorCode;

  // 로딩 상태 추적
  int _loadingTaskCount = 0;
  bool get isLoading => _loadingTaskCount > 0;

  /// 로딩 상태 추적 시작
  void startLoading() {
    _loadingTaskCount++;
    if (_loadingTaskCount == 1) {
      notifyListeners();
    }
  }

  /// 로딩 상태 추적 종료
  void finishLoading() {
    _loadingTaskCount--;
    if (_loadingTaskCount == 0) {
      notifyListeners();
    }
  }

  /// 에러 상태 설정 (오류 종류에 따라 다른 UI 제공)
  LoadingStateType setErrorState(dynamic error) {
    LoadingStateType resultState;
    _lastErrorCode = null;

    if (error is NetworkException) {
      _lastErrorCode = error.statusCode;

      if (error.isNetwork) {
        // 네트워크 오류인 경우 네트워크 오류 상태로 설정
        _isNetworkError = true;
        _errorMessage = ErrorHandlingUtil.getNetworkErrorMessage(error);
        resultState = LoadingStateType.networkError;
      } else {
        // 일반 오류
        _isNetworkError = false;
        _errorMessage = error.message;
        resultState = LoadingStateType.error;
      }
    } else if (error is DioException) {
      // Dio 오류 직접 처리
      _isNetworkError = true;
      _lastErrorCode = error.response?.statusCode;
      _errorMessage = ErrorHandlingUtil.getDioErrorMessage(error);
      resultState = LoadingStateType.networkError;
    } else if (error is CouponException) {
      // 쿠폰 오류 처리
      _isNetworkError = error.type == CouponErrorType.networkError;
      _lastErrorCode = error.statusCode;
      _errorMessage = ErrorHandlingUtil.getCouponErrorMessage(error);
      resultState = _isNetworkError
          ? LoadingStateType.networkError
          : LoadingStateType.error;
    } else if (error is AuthException) {
      // 인증 오류 처리
      _isNetworkError = error.type == AuthErrorType.networkError;
      _lastErrorCode = error.statusCode;
      _errorMessage = ErrorHandlingUtil.getAuthErrorMessage(error);
      resultState = _isNetworkError
          ? LoadingStateType.networkError
          : LoadingStateType.error;
    } else {
      // 일반 오류
      _isNetworkError = false;
      _errorMessage = ErrorHandlingUtil.getGenericErrorMessage(error);
      resultState = LoadingStateType.error;
    }

    if (kDebugMode) {
      LoggerUtil.e(
          '오류 상태 설정: $resultState, 메시지: $_errorMessage, 코드: $_lastErrorCode');
    }

    return resultState;
  }

  /// 에러 메시지 초기화
  void clearError() {
    _errorMessage = '';
    _isNetworkError = false;
    _lastErrorCode = null;
    notifyListeners();
  }

  /// 모든 상태 및 에러 초기화 (내부용)
  void clearErrorState() {
    _errorMessage = '';
    _isNetworkError = false;
    _lastErrorCode = null;
  }
}

/// StateNotifier 기반 ViewModel에서 오류 처리를 위한 Mixin
mixin StateNotifierErrorHandlingMixin<T> on StateNotifier<T> {
  // 에러 메시지
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // 네트워크 오류 여부
  bool _isNetworkError = false;
  bool get isNetworkError => _isNetworkError;

  // 오류 코드
  int? _lastErrorCode;
  int? get lastErrorCode => _lastErrorCode;

  // 로딩 상태 추적 (상태 업데이트는 구체적인 구현에서 처리)
  int _loadingTaskCount = 0;
  bool get isLoading => _loadingTaskCount > 0;

  /// 로딩 상태 추적 시작 (상속 클래스에서 state 업데이트 필요)
  void startLoading() {
    _loadingTaskCount++;
  }

  /// 로딩 상태 추적 종료 (상속 클래스에서 state 업데이트 필요)
  void finishLoading() {
    _loadingTaskCount--;
  }

  /// 에러 상태 설정 (오류 종류에 따라 다른 UI 제공)
  LoadingStateType setErrorState(dynamic error) {
    LoadingStateType resultState;
    _lastErrorCode = null;

    if (error is NetworkException) {
      _lastErrorCode = error.statusCode;

      if (error.isNetwork) {
        // 네트워크 오류인 경우 네트워크 오류 상태로 설정
        _isNetworkError = true;
        _errorMessage = ErrorHandlingUtil.getNetworkErrorMessage(error);
        resultState = LoadingStateType.networkError;
      } else {
        // 일반 오류
        _isNetworkError = false;
        _errorMessage = error.message;
        resultState = LoadingStateType.error;
      }
    } else if (error is DioException) {
      // Dio 오류 직접 처리
      _isNetworkError = true;
      _lastErrorCode = error.response?.statusCode;
      _errorMessage = ErrorHandlingUtil.getDioErrorMessage(error);
      resultState = LoadingStateType.networkError;
    } else if (error is CouponException) {
      // 쿠폰 오류 처리
      _isNetworkError = error.type == CouponErrorType.networkError;
      _lastErrorCode = error.statusCode;
      _errorMessage = ErrorHandlingUtil.getCouponErrorMessage(error);
      resultState = _isNetworkError
          ? LoadingStateType.networkError
          : LoadingStateType.error;
    } else if (error is AuthException) {
      // 인증 오류 처리
      _isNetworkError = error.type == AuthErrorType.networkError;
      _lastErrorCode = error.statusCode;
      _errorMessage = ErrorHandlingUtil.getAuthErrorMessage(error);
      resultState = _isNetworkError
          ? LoadingStateType.networkError
          : LoadingStateType.error;
    } else {
      // 일반 오류
      _isNetworkError = false;
      _errorMessage = ErrorHandlingUtil.getGenericErrorMessage(error);
      resultState = LoadingStateType.error;
    }

    if (kDebugMode) {
      LoggerUtil.e(
          '오류 상태 설정: $resultState, 메시지: $_errorMessage, 코드: $_lastErrorCode');
    }

    return resultState;
  }

  /// 에러 상태 초기화
  void clearErrorState() {
    _errorMessage = '';
    _isNetworkError = false;
    _lastErrorCode = null;
  }

  /// 에러 처리 헬퍼 메서드 - try-catch 블록에서 사용
  ///
  /// 사용 예시:
  /// ```dart
  /// try {
  ///   // 작업 수행
  /// } catch (e) {
  ///   return handleError(e, '작업 설명');
  /// }
  /// ```
  ///
  /// 반환 값은 에러 상태에 따라 다름:
  /// - 성공: true
  /// - 실패: false
  /// - 특별한 경우: 다른 값 (구체적인 구현에서 정의)
  dynamic handleError(dynamic error, String operationDescription) {
    final errorState = setErrorState(error);

    // 에러 로깅
    LoggerUtil.e('$operationDescription 실패', error);

    // 기본적으로 실패를 반환
    return false;
  }

  /// 에러 처리 헬퍼 메서드 - Future를 반환하는 작업에서 사용
  ///
  /// 사용 예시:
  /// ```dart
  /// return executeWithErrorHandling(
  ///   () => someAsyncOperation(),
  ///   '작업 설명',
  ///   onSuccess: (result) {
  ///     // 성공 시 처리
  ///   },
  ///   onError: (error) {
  ///     // 에러 시 추가 처리
  ///   },
  /// );
  /// ```
  Future<T?> executeWithErrorHandling<T>(
    Future<T> Function() operation,
    String operationDescription, {
    void Function(T)? onSuccess,
    void Function(dynamic)? onError,
  }) async {
    try {
      final result = await operation();
      if (onSuccess != null) {
        onSuccess(result);
      }
      return result;
    } catch (e) {
      final errorState = setErrorState(e);
      LoggerUtil.e('$operationDescription 실패', e);

      if (onError != null) {
        onError(e);
      }

      return null;
    }
  }
}
