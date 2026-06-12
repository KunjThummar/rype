import 'package:dio/dio.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static Future<bool> login(String email, String password) async {
    try {
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
            print('Token saved successfully');
            return true;
          } else {
            throw Exception('No token received from server');
          }
        }
      }
      throw Exception('Login failed: Invalid response format');
    } on DioException catch (e) {
      print('DioException: ${e.type} - ${e.message}');
      print('Response: ${e.response?.data}');
      
      final message = e.response?.data?['message'];
      if (message is List) {
        throw Exception(message.join(', '));
      }
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timeout. Please check your network and try again.');
      }
      
      if (e.type == DioExceptionType.unknown) {
        throw Exception('Network error. Please check your internet connection.');
      }
      
      throw Exception(message ?? e.message ?? 'Invalid credentials');
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to login: $e');
    }
  }

  static Future<bool> register(String fullName, String email, String password) async {
    try {
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
          return true;
        }
      }
      throw Exception('Registration failed: Invalid response format');
    } on DioException catch (e) {
      print('DioException: ${e.type} - ${e.message}');
      print('Response: ${e.response?.data}');
      
      final message = e.response?.data?['message'];
      if (message is List) {
        throw Exception(message.join(', '));
      }
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timeout. Please check your network and try again.');
      }
      
      if (e.type == DioExceptionType.unknown) {
        throw Exception('Network error. Please check your internet connection.');
      }
      
      throw Exception(message ?? e.message ?? 'Failed to register');
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to register: $e');
    }
  }

  static Future<void> logout() async {
    try {
      await StorageService.logout();
      print('Logged out successfully');
    } catch (e) {
      print('Error logging out: $e');
      rethrow;
    }
  }
}
