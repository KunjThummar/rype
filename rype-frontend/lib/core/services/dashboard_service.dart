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
  final double todaysGainLoss;
  final Map<String, double> allocation;
  final List<DashboardAsset> topGainers;
  final List<DashboardAsset> topLosers;
  final List<DashboardTransaction> recentTransactions;
  final double xirr;
  final double cagr;
  final BenchmarkComparison benchmarkComparison;

  DashboardSummary({
    required this.totalInvestment,
    required this.currentValue,
    required this.totalProfitLoss,
    required this.profitPercentage,
    required this.totalStocks,
    required this.totalMutualFunds,
    required this.todaysGainLoss,
    required this.allocation,
    required this.topGainers,
    required this.topLosers,
    required this.recentTransactions,
    required this.xirr,
    required this.cagr,
    required this.benchmarkComparison,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalInvestment: (json['totalInvestment'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      totalProfitLoss: (json['totalProfitLoss'] as num?)?.toDouble() ?? 0.0,
      profitPercentage:
          double.tryParse(json['profitPercentage'].toString()) ?? 0.0,
      totalStocks: (json['totalStocks'] as num?)?.toInt() ?? 0,
      totalMutualFunds: (json['totalMutualFunds'] as num?)?.toInt() ?? 0,
      todaysGainLoss: (json['todaysGainLoss'] as num?)?.toDouble() ?? 0.0,
      allocation: {
        'stocks':
            ((json['allocation'] as Map?)?['stocks'] as num?)?.toDouble() ??
            0.0,
        'mutualFunds':
            ((json['allocation'] as Map?)?['mutualFunds'] as num?)
                ?.toDouble() ??
            0.0,
      },
      topGainers: _assets(json['topGainers']),
      topLosers: _assets(json['topLosers']),
      recentTransactions: _transactions(json['recentTransactions']),
      xirr: (json['xirr'] as num?)?.toDouble() ?? 0.0,
      cagr: (json['cagr'] as num?)?.toDouble() ?? 0.0,
      benchmarkComparison: BenchmarkComparison.fromJson(
        Map<String, dynamic>.from(json['benchmarkComparison'] ?? {}),
      ),
    );
  }

  static List<DashboardAsset> _assets(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((item) => DashboardAsset.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static List<DashboardTransaction> _transactions(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map(
          (item) =>
              DashboardTransaction.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}

class BenchmarkComparison {
  final double portfolioReturn;
  final double niftyReturn;
  final double sensexReturn;
  final bool outperformedNifty;
  final bool outperformedSensex;

  BenchmarkComparison({
    required this.portfolioReturn,
    required this.niftyReturn,
    required this.sensexReturn,
    required this.outperformedNifty,
    required this.outperformedSensex,
  });

  factory BenchmarkComparison.fromJson(Map<String, dynamic> json) {
    return BenchmarkComparison(
      portfolioReturn: (json['portfolioReturn'] as num?)?.toDouble() ?? 0.0,
      niftyReturn: (json['niftyReturn'] as num?)?.toDouble() ?? 0.0,
      sensexReturn: (json['sensexReturn'] as num?)?.toDouble() ?? 0.0,
      outperformedNifty: json['outperformedNifty'] as bool? ?? false,
      outperformedSensex: json['outperformedSensex'] as bool? ?? false,
    );
  }
}

class DashboardAsset {
  DashboardAsset({
    required this.name,
    required this.type,
    required this.currentValue,
    required this.profitLoss,
    required this.profitPercent,
  });

  final String name;
  final String type;
  final double currentValue;
  final double profitLoss;
  final double profitPercent;

  factory DashboardAsset.fromJson(Map<String, dynamic> json) {
    return DashboardAsset(
      name: json['name'] as String? ?? '-',
      type: json['type'] as String? ?? '',
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      profitLoss: (json['profitLoss'] as num?)?.toDouble() ?? 0.0,
      profitPercent: (json['profitPercent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardTransaction {
  DashboardTransaction({
    required this.assetName,
    required this.symbol,
    required this.transactionType,
    required this.quantity,
    required this.price,
  });

  final String assetName;
  final String symbol;
  final String transactionType;
  final double quantity;
  final double price;

  factory DashboardTransaction.fromJson(Map<String, dynamic> json) {
    return DashboardTransaction(
      assetName: json['assetName'] as String? ?? '-',
      symbol: json['symbol'] as String? ?? '',
      transactionType: json['transactionType'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardService {
  static Future<DashboardSummary> getSummary() async {
    final token = await StorageService.getToken();

    final response = await ApiService.dio.get(
      '/dashboard/summary',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return DashboardSummary.fromJson(response.data as Map<String, dynamic>);
  }
}
