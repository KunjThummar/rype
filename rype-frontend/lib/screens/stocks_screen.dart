import 'package:flutter/material.dart';

import '../core/services/stock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_widgets.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  List<StockModel> _stocks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStocks());
  }

  Future<void> _loadStocks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stocks = await StockService.getStocks();
      if (!mounted) return;
      setState(() {
        _stocks = stocks;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Stocks could not be loaded. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _deleteStock(String id, String symbol) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Stock'),
        content: Text('Remove $symbol from your portfolio?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await StockService.deleteStock(id);
      _loadStocks();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete stock.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Stocks',
      actions: [
        if (!_loading && _stocks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(label: Text('${_stocks.length} holdings')),
          ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add-stock');
          _loadStocks();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Stock'),
      ),
      child: _loading
          ? const LoadingSkeleton()
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadStocks)
              : _stocks.isEmpty
                  ? const EmptyState(
                      icon: Icons.trending_up_rounded,
                      title: 'No stocks yet',
                      message: 'Add your first stock to start tracking performance.',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadStocks,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: _stocks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, index) => _StockCard(
                          stock: _stocks[index],
                          onDelete: () => _deleteStock(_stocks[index].id, _stocks[index].symbol),
                        ),
                      ),
                    ),
    );
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({required this.stock, required this.onDelete});

  final StockModel stock;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isProfit = stock.profitLoss >= 0;
    final color = isProfit ? context.finance.success : context.finance.danger;

    return FinanceCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stock.symbol.isEmpty ? 'S' : stock.symbol.substring(0, 1),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stock.symbol, style: Theme.of(context).textTheme.titleMedium),
                    Text(stock.stockName, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded, color: context.finance.danger),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: context.finance.border),
          const SizedBox(height: 14),
          Row(
            children: [
              _MiniStat(label: 'Qty', value: '${stock.quantity}'),
              _MiniStat(label: 'Buy', value: formatCurrency(stock.buyPrice)),
              _MiniStat(label: 'Current', value: formatCurrency(stock.currentPrice)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isProfit ? '+' : ''}${stock.profitPercent.toStringAsFixed(2)}%',
                      style: TextStyle(color: color, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${isProfit ? '+' : ''}${formatCurrency(stock.profitLoss)}',
                      style: TextStyle(color: color, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: Theme.of(context).textTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}
