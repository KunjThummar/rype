import 'package:dio/dio.dart';

import 'api_service.dart';
import 'storage_service.dart';

class HoldingsService {
  Future<Response> getHoldings() async {
    final token =
        await StorageService.getToken();

    return ApiService.dio.get(
      '/holdings',
      options: Options(
        headers: {
          'Authorization':
              'Bearer $token',
        },
      ),
    );
  }
}