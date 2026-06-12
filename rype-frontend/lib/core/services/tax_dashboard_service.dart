import 'package:dio/dio.dart';

import 'api_service.dart';
import 'storage_service.dart';

class TaxDashboardService {
  Future<Response> getDashboard() async {
    final token =
        await StorageService.getToken();

    return ApiService.dio.get(
      '/tax-dashboard',
      options: Options(
        headers: {
          'Authorization':
              'Bearer $token',
        },
      ),
    );
  }
}