import 'package:flutter/material.dart';

import '../core/services/what_if_service.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_widgets.dart';

class WhatIfScreen extends StatefulWidget {
  const WhatIfScreen({super.key});

  @override
  State<WhatIfScreen> createState() => _WhatIfScreenState();
}

class _WhatIfScreenState extends State<WhatIfScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symbol = TextEditingController();
  final _quantity = TextEditingController();
  final _sellPrice = TextEditingController();
  bool loading = false;
  String? error;
  Map<String, dynamic>? result;

  @override
  void dispose() {
    _symbol.dispose();
    _quantity.dispose();
    _sellPrice.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = null;
      result = null;
    });
    try {
      final response = await WhatIfService().analyze(
        symbol: _symbol.text.trim().toUpperCase(),
        quantity: int.parse(_quantity.text.trim()),
        sellPrice: double.parse(_sellPrice.text.trim()),
      );
      if (!mounted) return;
      final body = response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : <String, dynamic>{};
      setState(() {
        error = body['error']?.toString();
        result = body['error'] == null ? body : null;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'The analysis could not be completed. Check the inputs and try again.';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'What-If Analysis',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          FinanceCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sell Scenario', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _symbol,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Stock',
                      hintText: 'Example: TCS',
                      prefixIcon: Icon(Icons.business_center_outlined),
                    ),
                    validator: (value) => asText(value, '').isEmpty ? 'Enter a stock symbol' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _quantity,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      prefixIcon: Icon(Icons.numbers_rounded),
                    ),
                    validator: (value) {
                      final parsed = int.tryParse(asText(value, ''));
                      return parsed == null || parsed < 1 ? 'Enter a valid quantity' : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _sellPrice,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Sell Price',
                      prefixIcon: Icon(Icons.currency_rupee_rounded),
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(asText(value, ''));
                      return parsed == null || parsed <= 0 ? 'Enter a valid sell price' : null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: loading ? null : _analyze,
                      icon: loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.calculate_outlined),
                      label: const Text('Run Analysis'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            ErrorState(message: error!, onRetry: _analyze),
          ],
          if (result != null) ...[
            const SizedBox(height: 22),
            const SectionHeader(title: 'Projected Outcome'),
            const SizedBox(height: 12),
            _ResultGrid(result: result!),
            const SizedBox(height: 12),
            _RecommendationCard(result: result!),
          ] else if (!loading && error == null) ...[
            const SizedBox(height: 22),
            const EmptyState(
              icon: Icons.insights_outlined,
              title: 'Model a sell decision',
              message: 'Enter a stock, quantity, and price to estimate profit, taxes, and remaining holdings.',
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultGrid extends StatelessWidget {
  const _ResultGrid({required this.result});

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final profit = asDouble(result['estimatedProfit']);
    final tax = asDouble(result['estimatedTax']);
    return ResponsiveGrid(
      itemHeight: 120,
      children: [
        MetricCard(label: 'Expected Profit', value: formatCurrency(profit), icon: Icons.trending_up_rounded, accent: profit >= 0 ? context.finance.success : context.finance.danger),
        MetricCard(label: 'STCG', value: formatCurrency(asDouble(result['stcgGain'])), icon: Icons.bolt_outlined, accent: context.finance.warning),
        MetricCard(label: 'LTCG', value: formatCurrency(asDouble(result['ltcgGain'])), icon: Icons.calendar_month_outlined, accent: context.finance.success),
        MetricCard(label: 'Tax Liability', value: formatCurrency(tax), icon: Icons.receipt_long_outlined, accent: context.finance.danger),
        MetricCard(label: 'Remaining Holdings', value: asText(result['remainingQuantity'], '0'), icon: Icons.inventory_2_outlined),
        MetricCard(label: 'Tax Savings', value: formatCurrency(asDouble(result['potentialTaxSaving'])), icon: Icons.savings_outlined),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.result});

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final recommendation = asText(result['recommendation'], 'HOLD').replaceAll('_', ' ');
    final netProfit = asDouble(result['netProfit']);
    return FinanceCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.psychology_alt_outlined, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recommendation, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Estimated net profit: ${formatCurrency(netProfit)}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
