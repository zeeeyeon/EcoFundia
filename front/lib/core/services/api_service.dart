import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_service.dart';
import 'token_service.dart';
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
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      headers: {
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
      validateStatus: (status) {
        return true;
      },
    ));

    _setupInterceptors();

    LoggerUtil.i('📱 API 서비스 초기화 완료 - 기본 URL: $_baseUrl');
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final startTime = DateTime.now();
          LoggerUtil.d('🔄 API 요청 시작: ${options.method} ${options.path}');

          // Skip token for login and signup
          if (options.path == apiEndpoints.login ||
              options.path == apiEndpoints.signup ||
              options.headers.containsKey('X-Skip-Token-Refresh')) {
            return handler.next(options);
          }

          try {
            final token = await StorageService.getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
              LoggerUtil.d('🔑 인증 토큰 설정 완료');
            } else {
              LoggerUtil.w('⚠️ 인증 토큰 없음: ${options.path}');
            }
          } catch (e) {
            LoggerUtil.e('토큰 설정 중 오류', e);
          }

          options.extra['startTime'] = startTime;
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final startTime =
              response.requestOptions.extra['startTime'] as DateTime?;
          final endTime = DateTime.now();
          final duration =
              startTime != null ? endTime.difference(startTime) : null;

          // HTTP 상태 코드 색상 결정
          final status = response.statusCode ?? 0;
          String statusSymbol = '✅';
          if (status >= 400) statusSymbol = '⚠️';
          if (status >= 500) statusSymbol = '❌';

          LoggerUtil.d(
              '$statusSymbol API 응답 (${duration?.inMilliseconds ?? 0}ms): '
              '${response.requestOptions.method} ${response.requestOptions.path} '
              '- 상태: $status');

          // 응답 데이터 구조 체크
          if (response.data != null) {
            if (response.data is Map && response.data.containsKey('content')) {
              LoggerUtil.d('✓ 응답 데이터 구조 정상');
            } else {
              LoggerUtil.w('⚠️ 응답 데이터 구조 비정상: ${response.data.runtimeType}');
            }
          }

          return handler.next(response);
        },
        onError: (error, handler) async {
          final startTime =
              error.requestOptions.extra['startTime'] as DateTime?;
          final endTime = DateTime.now();
          final duration =
              startTime != null ? endTime.difference(startTime) : null;

          LoggerUtil.e('❌ API 오류 (${duration?.inMilliseconds ?? 0}ms): '
              '${error.requestOptions.method} ${error.requestOptions.path}'
              '- 메시지: ${error.message}');

          // 네트워크 연결 문제 디버깅
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            LoggerUtil.e('⏱️ 네트워크 타임아웃: ${error.type}');
          } else if (error.type == DioExceptionType.connectionError) {
            LoggerUtil.e('🌐 네트워크 연결 오류: ${error.message}');
          }

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
              LoggerUtil.i('🔄 토큰 갱신 시도 (API 인터셉터)');

              // 리프레시 토큰 가져오기
              final refreshToken = await StorageService.getRefreshToken();
              if (refreshToken == null) {
                LoggerUtil.w('⚠️ 리프레시 토큰 없음');
                throw DioException(
                    requestOptions: error.requestOptions,
                    error: '리프레시 토큰이 없습니다.');
              }

              // TokenService를 통한 토큰 갱신
              final newTokens = await TokenService.refreshTokens(refreshToken);
              if (newTokens != null) {
                // 새 토큰 저장
                await StorageService.saveToken(newTokens['accessToken']!);
                await StorageService.saveRefreshToken(
                    newTokens['refreshToken']!);

                // 실패한 요청 재시도
                error.requestOptions.headers['Authorization'] =
                    'Bearer ${newTokens['accessToken']}';
                LoggerUtil.i('🔄 실패한 요청 재시도: ${error.requestOptions.path}');
                final retryResponse = await _dio.fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              } else {
                // 토큰 갱신 실패 시 로그아웃 처리
                await StorageService.clearAll();
                LoggerUtil.i('👋 로그아웃 처리 (인증 실패)');
              }
            } catch (e) {
              LoggerUtil.e('❌ 토큰 갱신 실패', e);
              // 토큰 갱신 실패 시 로그아웃 처리
              await StorageService.clearAll();
              LoggerUtil.i('👋 로그아웃 처리 (인증 실패)');
            }
          }
          return handler.next(error);
        },
      ),
    );

    // 로깅 인터셉터 (옵션 - 디버깅 목적)
    if (true) {
      // 개발 환경에서만 활성화
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (object) => LoggerUtil.d(
            '🔍 ${object.toString().length > 1000 ? '${object.toString().substring(0, 1000)}...(잘림)' : object}'),
      ));
    }
  }

  /// GET 요청
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken}) async {
    try {
      LoggerUtil.d('🔄 GET 요청: $path, 파라미터: $queryParameters');

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      // 응답 분석 및 로깅
      if (response.statusCode == 200) {
        LoggerUtil.d('✅ GET 응답 성공 ($path): ${response.statusCode}');
      } else {
        LoggerUtil.w('⚠️ GET 응답 비정상 ($path): ${response.statusCode}');
      }

      return response;
    } catch (e) {
      LoggerUtil.e('❌ GET 요청 실패: $path', e);
      rethrow;
    }
  }

  /// POST 요청
  Future<Response> post(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    // 쿠폰 관련 API 호출 특별 로깅
    if (path.contains('coupons')) {
      LoggerUtil.i('🎫 쿠폰 API 호출: POST $path');
    }

    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      // 쿠폰 관련 API 응답 특별 로깅
      if (path.contains('coupons')) {
        LoggerUtil.i('🎫 쿠폰 API 응답: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      LoggerUtil.e('❌ POST 요청 실패: $path', e);
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

  /// 로그아웃 처리
  Future<bool> logout({CancelToken? cancelToken}) async {
    try {
      // 토큰 얻기 (요청 전 토큰 유효성 확인)
      final token = await StorageService.getToken();
      if (token == null) {
        LoggerUtil.w('⚠️ 로그아웃 요청을 위한 토큰이 없습니다. 로컬 스토리지만 초기화합니다.');
        await StorageService.clearAll();
        return true; // 토큰이 없으면 서버 요청 없이 로컬 스토리지만 초기화
      }

      // 서버에 로그아웃 요청 전송 (명시적으로 토큰 포함)
      await post(
        apiEndpoints.logout,
        options: Options(headers: {
          'X-Skip-Token-Refresh': 'true',
          'Authorization': 'Bearer $token', // 명시적 토큰 포함
        }),
        cancelToken: cancelToken,
      );

      // 서버 요청 성공 후 로컬 스토리지에서 토큰 및 사용자 정보 삭제
      await StorageService.clearAll();
      LoggerUtil.i('✅ 로그아웃 성공: 토큰 및 사용자 정보 삭제 완료');

      return true;
    } catch (e) {
      // 요청 취소를 확인
      if (e is DioException && e.type == DioExceptionType.cancel) {
        LoggerUtil.i('🛑 로그아웃 요청이 취소되었습니다.');
        // 요청이 취소되어도 로컬 스토리지는 비움
        await StorageService.clearAll();
        return true; // 로컬에서는 로그아웃 성공으로 처리
      }

      LoggerUtil.e('❌ 로그아웃 실패', e);
      // 서버 요청 실패해도 로컬 스토리지는 비움
      await StorageService.clearAll();
      return false;
    }
  }

  /// 네트워크 연결 테스트
  Future<bool> testConnection() async {
    try {
      LoggerUtil.i('🔄 네트워크 연결 테스트 시작');
      final response = await _dio.get(
        apiEndpoints.test,
        options: Options(
          headers: {'X-Skip-Token-Refresh': 'true'},
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final isSuccess = response.statusCode == 200;
      LoggerUtil.i(isSuccess
          ? '✅ 네트워크 연결 테스트 성공'
          : '⚠️ 네트워크 연결 테스트 실패: ${response.statusCode}');
      return isSuccess;
    } catch (e) {
      LoggerUtil.e('❌ 네트워크 연결 테스트 실패', e);
      return false;
    }
  }
}

// 문자열 길이의 최소값 계산 헬퍼 함수
int min(int a, int b) => a < b ? a : b;

// 1. 이미지 URL을 백엔드 프록시를 통해 가져오도록 변환하는 함수 추가
String getProxiedImageUrl(String originalUrl, {int? maxWidth, int? maxHeight}) {
  if (originalUrl.isEmpty) {
    LoggerUtil.w('빈 이미지 URL이 전달됨');
    return '';
  }

  try {
    // 이미 프록시된 URL인 경우
    if (originalUrl.startsWith('http://') ||
        originalUrl.startsWith('https://')) {
      // URL에 크기 제한 매개변수 추가 (CDN 또는 이미지 서버에서 지원하는 경우)
      final Uri uri = Uri.parse(originalUrl);

      // 이미 크기 제한 매개변수가 있는지 확인
      final Map<String, String> queryParams =
          Map<String, String>.from(uri.queryParameters);

      // 최대 크기 파라미터 추가
      if (maxWidth != null && !queryParams.containsKey('width')) {
        queryParams['width'] = maxWidth.toString();
      }

      if (maxHeight != null && !queryParams.containsKey('height')) {
        queryParams['height'] = maxHeight.toString();
      }

      // 새 URI 생성
      final newUri = uri.replace(queryParameters: queryParams);

      LoggerUtil.d('이미지 URL 처리됨: $newUri');
      return newUri.toString();
    }

    // 상대 URL인 경우 (서버 호스트 주소로 변환 필요)
    // 예시: /images/photo.jpg -> https://api.example.com/images/photo.jpg
    if (originalUrl.startsWith('/')) {
      const baseUrl = 'https://j12e206.p.ssafy.io'; // 실제 API 기본 URL로 교체 필요
      final fullUrl = '$baseUrl$originalUrl';

      LoggerUtil.d('상대 URL을 절대 URL로 변환: $fullUrl');
      return fullUrl;
    }

    return originalUrl;
  } catch (e) {
    LoggerUtil.e('이미지 URL 처리 중 오류 발생: $e, URL: $originalUrl');
    return originalUrl;
  }
}
