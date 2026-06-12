import 'package:flutter/material.dart';

import '../core/services/tax_dashboard_service.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_widgets.dart';

class TaxDashboardScreen extends StatefulWidget {
  const TaxDashboardScreen({super.key});

  @override
  State<TaxDashboardScreen> createState() => _TaxDashboardScreenState();
}

class _TaxDashboardScreenState extends State<TaxDashboardScreen> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    loadTaxDashboard();
  }

  Future<void> loadTaxDashboard() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await TaxDashboardService().getDashboard();
      if (!mounted) return;
      setState(() {
        data = response.data is Map<String, dynamic> ? response.data : {};
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Tax details could not be refreshed. Please try again.';
        loading = false;
      });
    }
  }

  double get stcg => asDouble(data?['stcgGain']);
  double get ltcg => asDouble(data?['ltcgGain']);
  double get stcgTax => asDouble(data?['stcgTax']);
  double get ltcgTax => asDouble(data?['ltcgTax']);
  double get totalTax => asDouble(data?['totalTax']);
  double get savings => (stcg * 0.075).clamp(0, double.infinity);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Tax Dashboard',
      child: loading
          ? const LoadingSkeleton()
          : error != null
              ? ErrorState(message: error!, onRetry: loadTaxDashboard)
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final hasData = [stcg, ltcg, stcgTax, ltcgTax, totalTax].any((value) => value != 0);
    if (!hasData) {
      return const EmptyState(
        icon: Icons.request_quote_outlined,
        title: 'No tax data available',
        message: 'Realized gains and estimated tax will appear after sell transactions are recorded.',
      );
    }

    return RefreshIndicator(
      onRefresh: loadTaxDashboard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ResponsiveGrid(
            itemHeight: 120,
            children: [
              MetricCard(label: 'STCG', value: formatCurrency(stcg), icon: Icons.bolt_outlined, accent: context.finance.warning),
              MetricCard(label: 'LTCG', value: formatCurrency(ltcg), icon: Icons.calendar_month_outlined, accent: context.finance.success),
              MetricCard(label: 'Total Tax', value: formatCurrency(totalTax), icon: Icons.receipt_long_outlined, accent: context.finance.danger),
              MetricCard(label: 'Estimated Savings', value: formatCurrency(savings), icon: Icons.savings_outlined, accent: Theme.of(context).colorScheme.primary),
            ],
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Gain Distribution'),
          const SizedBox(height: 12),
          FinanceCard(
            child: Row(
              children: [
                SimplePieChart(
                  values: [stcg.abs(), ltcg.abs()],
                  colors: [context.finance.warning, context.finance.success],
                  size: 118,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    children: [
                      _BreakdownRow(label: 'Short Term', color: context.finance.warning, value: formatCurrency(stcg)),
                      const SizedBox(height: 12),
                      _BreakdownRow(label: 'Long Term', color: context.finance.success, value: formatCurrency(ltcg)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Tax Breakdown'),
          const SizedBox(height: 12),
          FinanceCard(
            child: BarChart(
              labels: const ['STCG', 'LTCG', 'Total'],
              values: [stcgTax, ltcgTax, totalTax],
            ),
          ),
          const SizedBox(height: 12),
          FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Portfolio Health Score', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: totalTax <= 0 ? 0.88 : (1 - (totalTax / (stcg.abs() + ltcg.abs()).clamp(1, double.infinity))).clamp(0.0, 1.0),
                  minHeight: 10,
                  color: context.finance.success,
                  backgroundColor: context.finance.pageSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 10),
                Text('Tax efficiency improves when short-term gains move into long-term buckets.', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.label, required this.color, required this.value});

  final String label;
  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
