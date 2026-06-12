import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.type == DioExceptionType.connectionTimeout) {
            print('Connection timeout: ${error.message}');
          } else if (error.type == DioExceptionType.receiveTimeout) {
            print('Receive timeout: ${error.message}');
          }
          return handler.next(error);
        },
      ),
    );
}
