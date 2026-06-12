import 'package:dio/dio.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  static Future<bool> login(String email, String password) async {
    int retries = 0;
    DioException? lastError;

    while (retries < _maxRetries) {
      try {
        print('📝 Login attempt ${retries + 1}/$_maxRetries for: $email');
        
        final response = await ApiService.dio.post(
          '/auth/login',
          data: {
            'email': email,
            'password': password,
          },
        );

        print('Login Response Status: ${response.statusCode}');
        print('Login Response Data: ${response.data}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          if (data != null && data['success'] == true) {
            final token = data['token'];
            if (token != null && token.isNotEmpty) {
              await StorageService.saveToken(token);
              print('✅ Token saved successfully');
              return true;
            } else {
              throw Exception('No token received from server');
            }
          }
        }
        throw Exception('Login failed: Invalid response format');
      } on DioException catch (e) {
        lastError = e;
        print('❌ DioException attempt $retries: ${e.type} - ${e.message}');
        print('Response: ${e.response?.data}');
        
        // Check if this is a retryable error
        bool isRetryable = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            (e.response?.statusCode ?? 0) >= 500; // Server errors

        retries++;
        
        if (isRetryable && retries < _maxRetries) {
          print('🔄 Retrying in ${_retryDelay.inSeconds}s...');
          await Future.delayed(_retryDelay);
          continue;
        } else {
          // Final error - not retryable or max retries reached
          final message = e.response?.data?['message'];
          if (message is List) {
            throw Exception(message.join(', '));
          }
          
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            throw Exception('Connection timeout after $retries attempts. Please check:\n'
                '1. Internet connection\n'
                '2. Backend URL: ${ApiService.dio.options.baseUrl}\n'
                '3. Backend server is running');
          }
          
          if (e.type == DioExceptionType.unknown) {
            throw Exception('Network error: ${e.message}\n'
                'Please check your internet connection and API URL');
          }
          
          throw Exception(message ?? e.message ?? 'Invalid credentials');
        }
      } catch (e) {
        print('❌ Exception attempt $retries: $e');
        retries++;
        
        if (retries < _maxRetries) {
          print('🔄 Retrying in ${_retryDelay.inSeconds}s...');
          await Future.delayed(_retryDelay);
        } else {
          throw Exception('Failed to login after $retries attempts: $e');
        }
      }
    }
    
    // Max retries exceeded
    throw Exception('Login failed after $_maxRetries attempts. Last error: ${lastError?.message}');
  }

  static Future<bool> register(String fullName, String email, String password) async {
    int retries = 0;
    DioException? lastError;

    while (retries < _maxRetries) {
      try {
        print('📝 Register attempt ${retries + 1}/$_maxRetries for: $email');
        
        final response = await ApiService.dio.post(
          '/auth/register',
          data: {
            'fullName': fullName,
            'email': email,
            'password': password,
          },
        );

        print('Register Response Status: ${response.statusCode}');
        print('Register Response Data: ${response.data}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          if (data != null && data['success'] == true) {
            print('✅ Registration successful');
            return true;
          }
        }
        throw Exception('Registration failed: Invalid response format');
      } on DioException catch (e) {
        lastError = e;
        print('❌ DioException attempt $retries: ${e.type} - ${e.message}');
        print('Response: ${e.response?.data}');
        
        bool isRetryable = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            (e.response?.statusCode ?? 0) >= 500;

        retries++;
        
        if (isRetryable && retries < _maxRetries) {
          print('🔄 Retrying in ${_retryDelay.inSeconds}s...');
          await Future.delayed(_retryDelay);
          continue;
        } else {
          final message = e.response?.data?['message'];
          if (message is List) {
            throw Exception(message.join(', '));
          }
          
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            throw Exception('Connection timeout after $retries attempts. Please check:\n'
                '1. Internet connection\n'
                '2. Backend URL: ${ApiService.dio.options.baseUrl}\n'
                '3. Backend server is running');
          }
          
          if (e.type == DioExceptionType.unknown) {
            throw Exception('Network error: ${e.message}\n'
                'Please check your internet connection and API URL');
          }
          
          throw Exception(message ?? e.message ?? 'Failed to register');
        }
      } catch (e) {
        print('❌ Exception attempt $retries: $e');
        retries++;
        
        if (retries < _maxRetries) {
          print('🔄 Retrying in ${_retryDelay.inSeconds}s...');
          await Future.delayed(_retryDelay);
        } else {
          throw Exception('Failed to register after $retries attempts: $e');
        }
      }
    }
    
    throw Exception('Registration failed after $_maxRetries attempts. Last error: ${lastError?.message}');
  }

  static Future<void> logout() async {
    try {
      await StorageService.logout();
      print('✅ Logged out successfully');
    } catch (e) {
      print('❌ Error logging out: $e');
      rethrow;
    }
  }
}
