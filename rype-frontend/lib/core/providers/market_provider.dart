import 'dart:async';

import 'package:flutter/foundation.dart';

import '../repositories/market_repository.dart';

class MarketProvider extends ChangeNotifier {
  MarketProvider({MarketRepository? repository})
    : _repository = repository ?? MarketRepository();

  final MarketRepository _repository;
  Timer? _timer;
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.refreshPortfolioPrices();
    } catch (_) {
      _error = 'Market data could not be refreshed.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void startAutoRefresh({Duration interval = const Duration(minutes: 5)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
