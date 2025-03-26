import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://your-api-base-url.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // 인터셉터 추가
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // 요청 전처리
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 응답 후처리
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // 에러 처리
        return handler.next(e);
      },
    ),
  );

  return dio;
});
