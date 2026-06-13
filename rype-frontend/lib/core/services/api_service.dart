import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 45),
      sendTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status >= 200 && status < 300,
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('[API] ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('[API] ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('[API ERROR] ${error.type}: ${error.message}');
          if (error.type == DioExceptionType.connectionTimeout) {
            debugPrint('Connection timeout - backend may be slow or unreachable');
          } else if (error.type == DioExceptionType.receiveTimeout) {
            debugPrint('Receive timeout - response is taking too long');
          } else if (error.type == DioExceptionType.unknown) {
            debugPrint('Network error - check internet connection and API URL');
            debugPrint('Current API URL: ${ApiConstants.baseUrl}');
          }
          return handler.next(error);
        },
      ),
    );
}
