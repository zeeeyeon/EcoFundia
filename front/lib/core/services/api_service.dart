import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_service.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/config/app_config.dart';

/// API 서비스 Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// API 요청을 처리하는 서비스
class ApiService {
  static ApiService? _instance;
  final Dio _dio = Dio();

  // 앱 설정에서 기본 URL 가져오기
  static const String _baseUrl = AppConfig.baseUrl;

  // 앱 설정에서 API 엔드포인트 가져오기
  static const apiEndpoints = AppConfig.apiEndpoints;

  // 싱글톤 패턴
  factory ApiService() {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  // 내부 생성자
  ApiService._internal() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.contentType = 'application/json; charset=utf-8';

    // 인터셉터 설정
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // 디버그 모드에서 로그 출력
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  /// 요청 전처리
  void _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (kDebugMode) {
      LoggerUtil.d('🔄 API 요청: ${options.method} ${options.path}');
    }

    // JWT 토큰 추가
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  /// 응답 처리
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      LoggerUtil.d(
          '✅ API 응답: ${response.statusCode} ${response.requestOptions.path}');
    }
    return handler.next(response);
  }

  /// 에러 처리
  void _onError(DioException e, ErrorInterceptorHandler handler) async {
    LoggerUtil.e(
        '❌ API 오류: ${e.response?.statusCode} ${e.requestOptions.path}', e);

    // 401 에러 시 토큰 갱신 시도
    if (e.response?.statusCode == 401) {
      try {
        LoggerUtil.i('🔄 토큰 갱신 시도');
        final refreshed = await _refreshToken();
        if (refreshed) {
          // 토큰 갱신 성공 시 원래 요청 재시도
          LoggerUtil.i('✅ 토큰 갱신 성공, 요청 재시도');
          final token = await StorageService.getToken();
          final options = e.requestOptions;
          options.headers['Authorization'] = 'Bearer $token';

          final response = await _dio.fetch(options);
          return handler.resolve(response);
        } else {
          LoggerUtil.w('⚠️ 토큰 갱신 실패');
        }
      } catch (error) {
        LoggerUtil.e('❌ 토큰 갱신 중 오류', error);
        // 토큰 갱신 실패 시 로그아웃 처리
        await StorageService.clearAll();
        LoggerUtil.i('🚪 자동 로그아웃 처리됨');
      }
    }

    return handler.next(e);
  }

  /// 토큰 갱신
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();

      if (refreshToken == null) {
        LoggerUtil.w('⚠️ 리프레시 토큰이 없음');
        return false;
      }

      final response = await _dio.post(
        apiEndpoints.refresh,
        options: Options(headers: {
          'Authorization': 'Bearer $refreshToken',
        }),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final content = data['content'];

        if (content != null && content['accessToken'] != null) {
          final newAccessToken = content['accessToken'];
          await StorageService.saveToken(newAccessToken);
          LoggerUtil.i('✅ 새 액세스 토큰 저장됨');

          // 리프레시 토큰도 함께 응답으로 오는 경우 저장
          if (content['refreshToken'] != null) {
            final newRefreshToken = content['refreshToken'];
            await StorageService.saveRefreshToken(newRefreshToken);
            LoggerUtil.i('✅ 새 리프레시 토큰 저장됨');
          }

          return true;
        }
      }

      return false;
    } catch (e) {
      LoggerUtil.e('❌ 토큰 갱신 요청 실패', e);
      return false;
    }
  }

  /// GET 요청
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      LoggerUtil.e('❌ GET 요청 실패: $path', e);
      rethrow;
    }
  }

  /// POST 요청
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      LoggerUtil.e('❌ POST 요청 실패: $path', e);
      rethrow;
    }
  }

  /// PUT 요청
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      LoggerUtil.e('❌ PUT 요청 실패: $path', e);
      rethrow;
    }
  }

  /// DELETE 요청
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } catch (e) {
      LoggerUtil.e('❌ DELETE 요청 실패: $path', e);
      rethrow;
    }
  }

  /// 현재 Dio 인스턴스 반환 (특수 케이스 처리용)
  Dio get dio => _dio;
}

// 문자열 길이의 최소값 계산 헬퍼 함수
int min(int a, int b) => a < b ? a : b;
