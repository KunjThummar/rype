import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      // Increased timeouts for production/slow connections
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      validateStatus: (status) => status != null && status < 500,
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🔵 [API] ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('🟢 [API] ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('🔴 [API ERROR] ${error.type}: ${error.message}');
          if (error.type == DioExceptionType.connectionTimeout) {
            print('⏱️ Connection timeout - Backend may be slow or unreachable');
          } else if (error.type == DioExceptionType.receiveTimeout) {
            print('⏱️ Receive timeout - Response taking too long');
          } else if (error.type == DioExceptionType.unknown) {
            print('❌ Network error - Check internet connection and API URL');
            print('   Current API URL: ${ApiConstants.baseUrl}');
          }
          return handler.next(error);
        },
      ),
    );
}
