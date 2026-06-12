import 'package:dio/dio.dart';

import 'api_service.dart';
import 'storage_service.dart';

class MutualFundService {
  Future<Response> getFunds() async {
    final token =
        await StorageService.getToken();

    return ApiService.dio.get(
      '/mutual-funds',
      options: Options(
        headers: {
          'Authorization':
              'Bearer $token',
        },
      ),
    );
  }

  Future<Response> createFund(
    Map<String, dynamic> data,
  ) async {
    final token =
        await StorageService.getToken();

    return ApiService.dio.post(
      '/mutual-funds',
      data: data,
      options: Options(
        headers: {
          'Authorization':
              'Bearer $token',
        },
      ),
    );
  }

  Future<Response> deleteFund(
    String id,
  ) async {
    final token =
        await StorageService.getToken();

    return ApiService.dio.delete(
      '/mutual-funds/$id',
      options: Options(
        headers: {
          'Authorization':
              'Bearer $token',
        },
      ),
    );
  }
}