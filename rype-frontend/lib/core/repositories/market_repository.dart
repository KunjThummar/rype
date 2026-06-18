import '../services/market_data_service.dart';

class MarketRepository {
  MarketRepository({MarketDataService? service})
    : _service = service ?? MarketDataService();

  final MarketDataService _service;
  final Map<String, _CacheEntry<Map<String, dynamic>>> _cache = {};
  final Duration _ttl = const Duration(minutes: 5);

  Future<Map<String, dynamic>> getStockPrice(String symbol) {
    return _cached(
      'stock:${symbol.toUpperCase()}',
      () => _service.getStockPrice(symbol),
    );
  }

  Future<Map<String, dynamic>> getNav(String amfiCode) {
    return _cached('nav:$amfiCode', () => _service.getNav(amfiCode));
  }

  Future<void> refreshPortfolioPrices() async {
    await _retry(_service.refreshStocks);
    await _retry(_service.refreshMutualFunds);
    _cache.clear();
  }

  Future<T> _cached<T>(String key, Future<T> Function() loader) async {
    final cached = _cache[key];
    if (cached != null && cached.expiresAt.isAfter(DateTime.now())) {
      return cached.value as T;
    }

    final value = await _retry(loader);
    if (value is Map<String, dynamic>) {
      _cache[key] = _CacheEntry(value, DateTime.now().add(_ttl));
    }
    return value;
  }

  Future<T> _retry<T>(Future<T> Function() action) async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await action();
      } catch (error) {
        lastError = error;
        if (attempt < 2) {
          await Future<void>.delayed(
            Duration(milliseconds: 300 * (attempt + 1)),
          );
        }
      }
    }
    throw lastError ?? Exception('Request failed');
  }
}

class _CacheEntry<T> {
  _CacheEntry(this.value, this.expiresAt);

  final T value;
  final DateTime expiresAt;
}
