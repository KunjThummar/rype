import 'package:dio/dio.dart';

import 'api_service.dart';
import 'storage_service.dart';

class MarketDataService {
  Future<Options> _authOptions() async {
    final token = await StorageService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<Map<String, dynamic>> getStockPrice(String symbol) async {
    final response = await ApiService.dio.get('/market-data/stock/$symbol');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getNav(String amfiCode) async {
    final response = await ApiService.dio.get('/market-data/nav/$amfiCode');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> refreshStocks() async {
    await ApiService.dio.post(
      '/stocks/refresh-prices',
      options: await _authOptions(),
    );
  }

  Future<void> refreshMutualFunds() async {
    await ApiService.dio.post(
      '/mutual-funds/refresh-navs',
      options: await _authOptions(),
    );
  }
}
