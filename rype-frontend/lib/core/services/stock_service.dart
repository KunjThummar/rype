import 'package:dio/dio.dart';
import 'api_service.dart';
import 'storage_service.dart';

class StockModel {
  final String id;
  final String stockName;
  final String symbol;
  final int quantity;
  final double buyPrice;
  final double currentPrice;
  final double investmentAmount;
  final double currentValue;
  final double profitLoss;
  final double profitPercent;

  StockModel({
    required this.id,
    required this.stockName,
    required this.symbol,
    required this.quantity,
    required this.buyPrice,
    required this.currentPrice,
    required this.investmentAmount,
    required this.currentValue,
    required this.profitLoss,
    required this.profitPercent,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      stockName: json['stockName'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      buyPrice: (json['buyPrice'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      investmentAmount: (json['investmentAmount'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      profitLoss: (json['profitLoss'] as num?)?.toDouble() ?? 0.0,
      profitPercent: (json['profitPercent'] as num?)?.toDouble() ?? 
                     (json['profitPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class StockService {
  static Future<Options> _authOptions() async {
    final token = await StorageService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  static Future<List<StockModel>> getStocks() async {
    try {
      final response = await ApiService.dio.get(
        '/stocks',
        options: await _authOptions(),
      );
      if (response.data is List) {
        final list = response.data as List<dynamic>;
        return list
            .map((e) {
              if (e is Map<String, dynamic>) {
                return StockModel.fromJson(e);
              }
              return null;
            })
            .whereType<StockModel>()
            .toList();
      }
      return [];
    } catch (_) {
      rethrow;
    }
  }

  static Future<void> createStock(Map<String, dynamic> data) async {
    await ApiService.dio.post(
      '/stocks',
      data: data,
      options: await _authOptions(),
    );
  }

  static Future<void> deleteStock(String id) async {
    await ApiService.dio.delete(
      '/stocks/$id',
      options: await _authOptions(),
    );
  }
}
