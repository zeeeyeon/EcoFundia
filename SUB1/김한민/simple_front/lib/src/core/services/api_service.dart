import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// API 요청을 처리하는 서비스
class ApiService {
  static ApiService? _instance;
  final Dio _dio = Dio();

  // 기본 URL (개발/운영 환경에 따라 변경 가능)
  static const String _baseUrl = 'https://api.simple.com/api';

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
    // JWT 토큰 추가
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  /// 응답 처리
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  /// 에러 처리
  void _onError(DioException e, ErrorInterceptorHandler handler) async {
    // 401 에러 시 토큰 갱신 시도
    if (e.response?.statusCode == 401) {
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // 토큰 갱신 성공 시 원래 요청 재시도
          final token = await StorageService.getToken();
          final options = e.requestOptions;
          options.headers['Authorization'] = 'Bearer $token';

          final response = await _dio.fetch(options);
          return handler.resolve(response);
        }
      } catch (error) {
        // 토큰 갱신 실패 시 로그아웃 처리
        await StorageService.clearUserData();
        // TODO: 로그인 화면으로 이동 로직
      }
    }

    return handler.next(e);
  }

  /// 토큰 갱신
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();

      if (refreshToken == null) {
        return false;
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        await StorageService.saveToken(newToken);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// GET 요청
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  /// POST 요청
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// PUT 요청
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE 요청
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } catch (e) {
      rethrow;
    }
  }
}
