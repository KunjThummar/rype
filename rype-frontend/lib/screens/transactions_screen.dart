import 'package:flutter/material.dart';

import '../core/services/transaction_service.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_widgets.dart';

enum TxFilter { all, buy, sell }

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List transactions = [];
  bool loading = true;
  String? error;
  String query = '';
  TxFilter type = TxFilter.all;
  DateTimeRange? dateRange;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await TransactionService().getTransactions();
      if (!mounted) return;
      setState(() {
        transactions = response.data is List ? response.data : [];
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Transactions could not be loaded. Please retry in a moment.';
        loading = false;
      });
    }
  }

  List get filteredTransactions {
    final text = query.toLowerCase();
    final filtered = transactions.where((tx) {
      final symbol = asText(tx['symbol']).toLowerCase();
      final txType = asText(tx['transactionType'] ?? tx['type']).toUpperCase();
      final date = _dateOf(tx);
      final matchesQuery = symbol.contains(text);
      final matchesType = type == TxFilter.all ||
          (type == TxFilter.buy && txType == 'BUY') ||
          (type == TxFilter.sell && txType == 'SELL');
      final matchesDate = dateRange == null ||
          (date != null &&
              !date.isBefore(dateRange!.start) &&
              !date.isAfter(dateRange!.end.add(const Duration(days: 1))));
      return matchesQuery && matchesType && matchesDate;
    }).toList();
    filtered.sort((a, b) {
      final ad = _dateOf(a) ?? DateTime(1970);
      final bd = _dateOf(b) ?? DateTime(1970);
      return bd.compareTo(ad);
    });
    return filtered;
  }

  DateTime? _dateOf(dynamic tx) {
    final raw = tx['date'] ?? tx['transactionDate'] ?? tx['createdAt'];
    return DateTime.tryParse(asText(raw, ''));
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
      initialDateRange: dateRange,
    );
    if (selected != null) setState(() => dateRange = selected);
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Transactions',
      child: loading
          ? const LoadingSkeleton()
          : error != null
              ? ErrorState(message: error!, onRetry: loadTransactions)
              : transactions.isEmpty
                  ? const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No transactions yet',
                      message: 'Buy and sell activity will appear here as a clean timeline.',
                    )
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final items = filteredTransactions;
    return RefreshIndicator(
      onRefresh: loadTransactions,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextField(
            onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search transactions',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: type == TxFilter.all,
                onSelected: (_) => setState(() => type = TxFilter.all),
              ),
              ChoiceChip(
                label: const Text('BUY'),
                selected: type == TxFilter.buy,
                onSelected: (_) => setState(() => type = TxFilter.buy),
              ),
              ChoiceChip(
                label: const Text('SELL'),
                selected: type == TxFilter.sell,
                onSelected: (_) => setState(() => type = TxFilter.sell),
              ),
              ActionChip(
                avatar: const Icon(Icons.date_range_rounded, size: 16),
                label: Text(dateRange == null ? 'Date Range' : 'Date Applied'),
                onPressed: _pickDateRange,
              ),
              if (dateRange != null)
                ActionChip(
                  avatar: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Clear Date'),
                  onPressed: () => setState(() => dateRange = null),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const EmptyState(
              icon: Icons.manage_search_rounded,
              title: 'No matching transactions',
              message: 'Try a different symbol, type, or date range.',
            )
          else
            for (var index = 0; index < items.length; index++)
              _TimelineItem(
                tx: items[index],
                isLast: index == items.length - 1,
                date: _dateOf(items[index]),
              ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.tx, required this.isLast, required this.date});

  final dynamic tx;
  final bool isLast;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final rawType = asText(tx['transactionType'] ?? tx['type'], 'BUY').toUpperCase();
    final isBuy = rawType == 'BUY';
    final color = isBuy ? Theme.of(context).colorScheme.primary : context.finance.warning;
    final profit = asDouble(tx['realizedProfit'] ?? tx['profitLoss'] ?? tx['profit']);
    final profitColor = profit >= 0 ? context.finance.success : context.finance.danger;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 22),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 1, color: context.finance.border),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FinanceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(rawType, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(asText(tx['symbol']), style: Theme.of(context).textTheme.titleMedium),
                        ),
                        Text(
                          _formatDate(date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 18,
                      runSpacing: 10,
                      children: [
                        _TxFact(label: 'Quantity', value: asText(tx['quantity'], '0')),
                        _TxFact(label: 'Price', value: formatCurrency(asDouble(tx['price']))),
                        _TxFact(
                          label: 'Profit/Loss',
                          value: '${profit >= 0 ? '+' : ''}${formatCurrency(profit)}',
                          color: profitColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _TxFact extends StatelessWidget {
  const _TxFact({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
