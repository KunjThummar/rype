import 'package:dio/dio.dart';

import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static const int _maxRetries = 2;
  static const Duration _retryDelay = Duration(seconds: 2);

  static Future<bool> login(String email, String password) async {
    int retries = 0;
    DioException? lastError;

    while (retries < _maxRetries) {
      try {
        final response = await ApiService.dio.post(
          '/auth/login',
          data: {
            'email': email,
            'password': password,
          },
        );

        final data = response.data;
        final token = data is Map<String, dynamic> ? data['token'] : null;

        if (data is Map<String, dynamic> && data['success'] == true && token is String && token.isNotEmpty) {
          await StorageService.saveToken(token);
          return true;
        }

        throw Exception('Login failed: invalid server response');
      } on DioException catch (e) {
        lastError = e;

        if (_isRetryable(e) && retries + 1 < _maxRetries) {
          retries++;
          await Future.delayed(_retryDelay);
          continue;
        }

        throw Exception(_messageFromDioError(e, 'Invalid credentials'));
      } catch (e) {
        throw Exception(e.toString().replaceFirst('Exception: ', ''));
      }
    }

    throw Exception('Login failed. Last error: ${lastError?.message}');
  }

  static Future<bool> register(String fullName, String email, String password) async {
    int retries = 0;
    DioException? lastError;

    while (retries < _maxRetries) {
      try {
        final response = await ApiService.dio.post(
          '/auth/register',
          data: {
            'fullName': fullName,
            'email': email,
            'password': password,
          },
        );

        final data = response.data;

        if (data is Map<String, dynamic> && data['success'] == true) {
          return true;
        }

        throw Exception('Registration failed: invalid server response');
      } on DioException catch (e) {
        lastError = e;

        if (_isRetryable(e) && retries + 1 < _maxRetries) {
          retries++;
          await Future.delayed(_retryDelay);
          continue;
        }

        throw Exception(_messageFromDioError(e, 'Failed to register'));
      } catch (e) {
        throw Exception(e.toString().replaceFirst('Exception: ', ''));
      }
    }

    throw Exception('Registration failed. Last error: ${lastError?.message}');
  }

  static Future<void> logout() async {
    await StorageService.logout();
  }

  static bool _isRetryable(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode ?? 0) >= 500;
  }

  static String _messageFromDioError(DioException error, String fallback) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    final serverMessage = _extractServerMessage(responseData);

    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    if (statusCode == 401) {
      return 'Invalid email or password';
    }

    if (statusCode == 400 || statusCode == 409) {
      return fallback;
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      return 'Cannot reach the server. Please check your internet connection or try again in a moment.';
    }

    return error.message ?? fallback;
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final message = data['message'];
    if (message is String) {
      return message;
    }

    if (message is List) {
      return message.join(', ');
    }

    return null;
  }
}
