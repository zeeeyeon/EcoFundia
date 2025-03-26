import 'package:dio/dio.dart';
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
  late final Dio _dio;

  // dio getter 추가
  Dio get dio => _dio;

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
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      contentType: 'application/json',
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip token for login and signup
          if (options.path == apiEndpoints.login ||
              options.path == apiEndpoints.signup ||
              options.headers.containsKey('X-Skip-Token-Refresh')) {
            return handler.next(options);
          }

          final token = await StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // 로그인, 회원가입, 토큰 갱신 요청에서는 토큰 갱신을 시도하지 않음
          if (error.requestOptions.path == apiEndpoints.login ||
              error.requestOptions.path == apiEndpoints.signup ||
              error.requestOptions.path == apiEndpoints.reissue ||
              error.requestOptions.headers
                  .containsKey('X-Skip-Token-Refresh')) {
            return handler.next(error);
          }

          if (error.response?.statusCode == 401) {
            try {
              final refreshToken = await StorageService.getRefreshToken();
              if (refreshToken == null) {
                throw DioException(
                    requestOptions: error.requestOptions,
                    error: '리프레시 토큰이 없습니다.');
              }

              // 토큰 갱신 시도
              final response = await _dio.post(
                apiEndpoints.reissue,
                data: {'refreshToken': refreshToken},
                options: Options(headers: {'X-Skip-Token-Refresh': 'true'}),
              );

              if (response.data != null) {
                final newAccessToken = response.data['content']['accessToken'];
                final newRefreshToken =
                    response.data['content']['refreshToken'];

                // 새 토큰 저장
                await StorageService.saveToken(newAccessToken);
                await StorageService.saveRefreshToken(newRefreshToken);

                // 실패한 요청 재시도
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final retryResponse = await _dio.fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              }
            } catch (e) {
              LoggerUtil.e('토큰 갱신 실패', e);
              // 토큰 갱신 실패 시 로그아웃 처리
              await StorageService.clearAll();
            }
          }
          return handler.next(error);
        },
      ),
    );

    // 로깅 인터셉터
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (object) => LoggerUtil.d('API 요청/응답: $object'),
    ));
  }

  /// GET 요청
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken}) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      LoggerUtil.e('GET 요청 실패: $path', e);
      rethrow;
    }
  }

  /// POST 요청
  Future<Response> post(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken}) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      LoggerUtil.e('POST 요청 실패: $path', e);
      rethrow;
    }
  }

  /// PUT 요청
  Future<Response> put(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken}) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      LoggerUtil.e('PUT 요청 실패: $path', e);
      rethrow;
    }
  }

  /// DELETE 요청
  Future<Response> delete(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken}) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      LoggerUtil.e('DELETE 요청 실패: $path', e);
      rethrow;
    }
  }
}

// 문자열 길이의 최소값 계산 헬퍼 함수
int min(int a, int b) => a < b ? a : b;
