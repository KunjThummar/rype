import 'package:flutter/material.dart';

import '../core/services/holdings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_widgets.dart';

enum HoldingSort { symbol, value, profit, roi }

class HoldingsScreen extends StatefulWidget {
  const HoldingsScreen({super.key});

  @override
  State<HoldingsScreen> createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends State<HoldingsScreen> {
  List holdings = [];
  bool loading = true;
  String? error;
  String query = '';
  bool profitOnly = false;
  HoldingSort sort = HoldingSort.value;

  @override
  void initState() {
    super.initState();
    loadHoldings();
  }

  Future<void> loadHoldings() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await HoldingsService().getHoldings();
      if (!mounted) return;
      setState(() {
        holdings = response.data is List ? response.data : [];
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Holdings could not be fetched right now. Please retry in a moment.';
        loading = false;
      });
    }
  }

  List get filteredHoldings {
    final text = query.toLowerCase();
    final filtered = holdings.where((holding) {
      final symbol = asText(holding['symbol']).toLowerCase();
      final company = asText(holding['companyName'] ?? holding['name']).toLowerCase();
      final pnl = _profitLoss(holding);
      final matches = symbol.contains(text) || company.contains(text);
      return matches && (!profitOnly || pnl >= 0);
    }).toList();

    filtered.sort((a, b) {
      switch (sort) {
        case HoldingSort.symbol:
          return asText(a['symbol']).compareTo(asText(b['symbol']));
        case HoldingSort.value:
          return _currentValue(b).compareTo(_currentValue(a));
        case HoldingSort.profit:
          return _profitLoss(b).compareTo(_profitLoss(a));
        case HoldingSort.roi:
          return _roi(b).compareTo(_roi(a));
      }
    });
    return filtered;
  }

  double _quantity(dynamic holding) => asDouble(holding['quantity']);
  double _avgPrice(dynamic holding) => asDouble(holding['averageBuyPrice'] ?? holding['avgBuyPrice']);
  double _marketPrice(dynamic holding) {
    final cmp = asDouble(holding['currentMarketPrice'] ?? holding['currentPrice'] ?? holding['marketPrice']);
    return cmp > 0 ? cmp : _avgPrice(holding);
  }

  double _invested(dynamic holding) {
    final invested = asDouble(holding['investedAmount']);
    return invested > 0 ? invested : _quantity(holding) * _avgPrice(holding);
  }

  double _currentValue(dynamic holding) => _quantity(holding) * _marketPrice(holding);
  double _profitLoss(dynamic holding) => _currentValue(holding) - _invested(holding);
  double _roi(dynamic holding) {
    final invested = _invested(holding);
    if (invested == 0) return 0;
    return _profitLoss(holding) / invested * 100;
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Holdings',
      child: loading
          ? const LoadingSkeleton()
          : error != null
              ? ErrorState(message: error!, onRetry: loadHoldings)
              : holdings.isEmpty
                  ? const EmptyState(
                      icon: Icons.pie_chart_outline_rounded,
                      title: 'No holdings yet',
                      message: 'Add stocks or mutual funds to see your portfolio positions here.',
                    )
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final items = filteredHoldings;
    return RefreshIndicator(
      onRefresh: loadHoldings,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextField(
            onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search by stock or company',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                selected: profitOnly,
                onSelected: (value) => setState(() => profitOnly = value),
                label: const Text('Profitable'),
                avatar: Icon(Icons.trending_up_rounded, size: 16, color: context.finance.success),
              ),
              DropdownMenu<HoldingSort>(
                initialSelection: sort,
                width: 190,
                label: const Text('Sort'),
                onSelected: (value) => setState(() => sort = value ?? sort),
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: HoldingSort.value, label: 'Current Value'),
                  DropdownMenuEntry(value: HoldingSort.profit, label: 'Profit/Loss'),
                  DropdownMenuEntry(value: HoldingSort.roi, label: 'ROI'),
                  DropdownMenuEntry(value: HoldingSort.symbol, label: 'Symbol'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const EmptyState(
              icon: Icons.manage_search_rounded,
              title: 'No matching holdings',
              message: 'Adjust the search or filters to broaden the results.',
            )
          else
            for (final holding in items) ...[
              _HoldingCard(
                holding: holding,
                quantity: _quantity(holding),
                avgPrice: _avgPrice(holding),
                marketPrice: _marketPrice(holding),
                pnl: _profitLoss(holding),
                roi: _roi(holding),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _HoldingCard extends StatelessWidget {
  const _HoldingCard({
    required this.holding,
    required this.quantity,
    required this.avgPrice,
    required this.marketPrice,
    required this.pnl,
    required this.roi,
  });

  final dynamic holding;
  final double quantity;
  final double avgPrice;
  final double marketPrice;
  final double pnl;
  final double roi;

  @override
  Widget build(BuildContext context) {
    final isProfit = pnl >= 0;
    final color = isProfit ? context.finance.success : context.finance.danger;
    final symbol = asText(holding['symbol']);
    final company = asText(holding['companyName'] ?? holding['name'], 'Listed security');

    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  symbol.length <= 2 ? symbol : symbol.substring(0, 2),
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
                    Text(symbol, style: Theme.of(context).textTheme.titleMedium),
                    Text(company, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${isProfit ? '+' : ''}${formatCurrency(pnl)}', style: TextStyle(color: color, fontWeight: FontWeight.w800)),
                  Text('${isProfit ? '+' : ''}${roi.toStringAsFixed(2)}%', style: TextStyle(color: color, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: context.finance.border),
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              _Fact(label: 'Quantity', value: quantity.toStringAsFixed(quantity % 1 == 0 ? 0 : 2)),
              _Fact(label: 'Avg Buy', value: formatCurrency(avgPrice)),
              _Fact(label: 'Market Price', value: formatCurrency(marketPrice)),
              _Fact(label: 'Current Value', value: formatCurrency(quantity * marketPrice)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 3),
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
