import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/api_constants.dart';
import 'package:front/utils/logger_util.dart';

/// Dio 인스턴스를 제공하는 provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // 요청 인터셉터
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        LoggerUtil.d('🌐 API 요청: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        LoggerUtil.d('✅ API 응답: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (error, handler) {
        LoggerUtil.e('❌ API 오류: ${error.message}');
        return handler.next(error);
      },
    ),
  );

  return dio;
});
