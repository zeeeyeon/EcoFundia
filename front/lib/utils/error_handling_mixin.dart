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
    } else {
      // 일반 오류
      _isNetworkError = false;
      _errorMessage = '데이터를 불러오는데 실패했습니다. 다시 시도해 주세요.';
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
    } else {
      // 일반 오류
      _isNetworkError = false;
      _errorMessage = '데이터를 불러오는데 실패했습니다. 다시 시도해 주세요.';
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
}
