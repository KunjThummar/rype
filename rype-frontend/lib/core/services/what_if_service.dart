import 'package:dio/dio.dart';

import 'api_service.dart';
import 'storage_service.dart';

class WhatIfService {
  Future<Response> analyze({
    required String symbol,
    required int quantity,
    required double sellPrice,
  }) async {
    final token = await StorageService.getToken();

    return ApiService.dio.post(
      '/what-if',
      data: {
        'symbol': symbol,
        'quantity': quantity,
        'sellPrice': sellPrice,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
