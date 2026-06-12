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

    print('BASE URL: ${ApiService.dio.options.baseUrl}');
    print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          final token = data['token'];
          if (token != null) {
            await StorageService.saveToken(token);
            return true;
          }
        }
      }
      return false;
    } on DioException catch (e) {
      final message = e.response?.data?['message'];
      if (message is List) {
        throw Exception(message.join(', '));
      }
      throw Exception(message ?? 'Invalid credentials');
    } catch (e) {
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

    print('BASE URL: ${ApiService.dio.options.baseUrl}');
    print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      final message = e.response?.data?['message'];
      if (message is List) {
        throw Exception(message.join(', '));
      }
      throw Exception(message ?? 'Failed to register');
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }
}
