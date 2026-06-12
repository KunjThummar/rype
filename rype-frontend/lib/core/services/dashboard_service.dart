import 'package:dio/dio.dart';

import 'api_service.dart';
import 'storage_service.dart';

class DashboardSummary {
  final double totalInvestment;
  final double currentValue;
  final double totalProfitLoss;
  final double profitPercentage;
  final int totalStocks;
  final int totalMutualFunds;

  DashboardSummary({
    required this.totalInvestment,
    required this.currentValue,
    required this.totalProfitLoss,
    required this.profitPercentage,
    required this.totalStocks,
    required this.totalMutualFunds,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalInvestment: (json['totalInvestment'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      totalProfitLoss: (json['totalProfitLoss'] as num?)?.toDouble() ?? 0.0,
      profitPercentage: double.tryParse(json['profitPercentage'].toString()) ?? 0.0,
      totalStocks: (json['totalStocks'] as num?)?.toInt() ?? 0,
      totalMutualFunds: (json['totalMutualFunds'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardService {
  static Future<DashboardSummary> getSummary() async {
    final token = await StorageService.getToken();

    final response = await ApiService.dio.get(
      '/dashboard/summary',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return DashboardSummary.fromJson(response.data as Map<String, dynamic>);
  }
}
