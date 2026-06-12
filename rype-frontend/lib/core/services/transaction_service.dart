import 'package:dio/dio.dart';

import 'api_service.dart';
import 'storage_service.dart';

class TransactionService {
  Future<Response> getTransactions() async {
    final token =
        await StorageService.getToken();

    return ApiService.dio.get(
      '/transactions',
      options: Options(
        headers: {
          'Authorization':
              'Bearer $token',
        },
      ),
    );
  }
}