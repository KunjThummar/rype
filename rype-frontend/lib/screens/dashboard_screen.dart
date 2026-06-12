import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/dashboard_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/finance_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  String? _error;
  DashboardSummary? _summary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboard());
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await DashboardService.getSummary();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Your portfolio summary could not be refreshed. Check your connection and try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return PremiumScaffold(
      title: 'Rype',
      showBack: false,
      actions: [
        ThemeToggleButton(controller: themeController),
        IconButton(
          tooltip: 'Settings',
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _loading
            ? const LoadingSkeleton()
            : _error != null
                ? ErrorState(message: _error!, onRetry: _loadDashboard)
                : _buildContent(_summary!),
      ),
    );
  }

  Widget _buildContent(DashboardSummary summary) {
    final isProfit = summary.totalProfitLoss >= 0;
    final pnlColor = isProfit ? context.finance.success : context.finance.danger;
    final stockValue = summary.currentValue * 0.62;
    final mfValue = summary.currentValue * 0.38;

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _PortfolioHero(summary: summary, pnlColor: pnlColor, isProfit: isProfit),
          const SizedBox(height: 16),
          ResponsiveGrid(
            itemHeight: 122,
            children: [
              MetricCard(
                label: 'Total Investment',
                value: formatCurrency(summary.totalInvestment),
                icon: Icons.savings_outlined,
              ),
              MetricCard(
                label: 'Current Value',
                value: formatCurrency(summary.currentValue),
                icon: Icons.account_balance_wallet_outlined,
              ),
              MetricCard(
                label: 'Total Profit',
                value: '${isProfit ? '+' : ''}${formatCurrency(summary.totalProfitLoss)}',
                icon: isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                accent: pnlColor,
              ),
              MetricCard(
                label: 'ROI',
                value: '${isProfit ? '+' : ''}${summary.profitPercentage.toStringAsFixed(2)}%',
                icon: Icons.percent_rounded,
                accent: pnlColor,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Portfolio Analytics'),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              final cards = [
                _AllocationCard(stockValue: stockValue, mfValue: mfValue),
                _GrowthCard(currentValue: summary.currentValue),
                _PerformanceCard(profitPercentage: summary.profitPercentage),
              ];
              if (!wide) {
                return Column(
                  children: [
                    for (final card in cards) ...[card, const SizedBox(height: 12)],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    Expanded(child: cards[i]),
                    if (i != cards.length - 1) const SizedBox(width: 12),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          ResponsiveGrid(
            itemHeight: 110,
            children: [
              MetricCard(
                label: 'Diversification Score',
                value: '82/100',
                subtitle: 'Balanced exposure',
                icon: Icons.hub_outlined,
                accent: context.finance.success,
              ),
              MetricCard(
                label: 'Risk Score',
                value: 'Moderate',
                subtitle: 'Volatility controlled',
                icon: Icons.shield_outlined,
                accent: context.finance.warning,
              ),
              MetricCard(
                label: 'Portfolio Health',
                value: 'Good',
                subtitle: 'Review monthly',
                icon: Icons.health_and_safety_outlined,
                accent: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Market Movers'),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 700;
              final gainers = _MarketList(
                title: 'Top Gainers',
                positive: true,
                rows: const [
                  ('TCS', 'Tata Consultancy', 2.84),
                  ('HDFCBANK', 'HDFC Bank', 1.92),
                  ('INFY', 'Infosys', 1.47),
                ],
              );
              final losers = _MarketList(
                title: 'Top Losers',
                positive: false,
                rows: const [
                  ('ITC', 'ITC Ltd', -1.38),
                  ('SBIN', 'State Bank', -1.12),
                  ('RELIANCE', 'Reliance Ind.', -0.86),
                ],
              );
              if (!wide) {
                return Column(children: [gainers, const SizedBox(height: 12), losers]);
              }
              return Row(children: [
                Expanded(child: gainers),
                const SizedBox(width: 12),
                Expanded(child: losers),
              ]);
            },
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 12),
          ResponsiveGrid(
            minItemWidth: 150,
            itemHeight: 92,
            children: [
              _ActionTile(icon: Icons.trending_up_rounded, label: 'Stocks', route: '/stocks'),
              _ActionTile(icon: Icons.account_balance_rounded, label: 'Mutual Funds', route: '/mutual-funds'),
              _ActionTile(icon: Icons.pie_chart_outline_rounded, label: 'Holdings', route: '/holdings'),
              _ActionTile(icon: Icons.receipt_long_rounded, label: 'Transactions', route: '/transactions'),
              _ActionTile(icon: Icons.request_quote_outlined, label: 'Tax Dashboard', route: '/tax-dashboard'),
              _ActionTile(icon: Icons.calculate_outlined, label: 'What-If Analysis', route: '/what-if'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PortfolioHero extends StatelessWidget {
  const _PortfolioHero({
    required this.summary,
    required this.pnlColor,
    required this.isProfit,
  });

  final DashboardSummary summary;
  final Color pnlColor;
  final bool isProfit;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back, Investor', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatCurrency(summary.currentValue),
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: pnlColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isProfit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      color: pnlColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isProfit ? '+' : ''}${summary.profitPercentage.toStringAsFixed(2)}%',
                      style: TextStyle(color: pnlColor, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Today: ${isProfit ? '+' : ''}${formatCurrency(summary.totalProfitLoss)} across ${summary.totalStocks + summary.totalMutualFunds} assets',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AllocationCard extends StatelessWidget {
  const _AllocationCard({required this.stockValue, required this.mfValue});

  final double stockValue;
  final double mfValue;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Asset Allocation', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 18),
          Center(
            child: SimplePieChart(
              values: [stockValue, mfValue],
              colors: [Theme.of(context).colorScheme.primary, context.finance.chartD],
            ),
          ),
          const SizedBox(height: 18),
          _Legend(label: 'Stocks', color: Theme.of(context).colorScheme.primary, value: formatCurrency(stockValue)),
          const SizedBox(height: 8),
          _Legend(label: 'Mutual Funds', color: context.finance.chartD, value: formatCurrency(mfValue)),
        ],
      ),
    );
  }
}

class _GrowthCard extends StatelessWidget {
  const _GrowthCard({required this.currentValue});

  final double currentValue;

  @override
  Widget build(BuildContext context) {
    final base = currentValue <= 0 ? 100000.0 : currentValue * 0.78;
    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Portfolio Growth', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          LineTrendChart(
            values: [
              base,
              base * 1.04,
              base * 0.99,
              base * 1.11,
              base * 1.16,
              currentValue <= 0 ? base * 1.22 : currentValue,
            ],
          ),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.profitPercentage});

  final double profitPercentage;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance Trend', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          BarChart(
            labels: const ['1W', '1M', '3M', '1Y'],
            values: [1.2, 3.8, profitPercentage / 2, profitPercentage],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.label, required this.color, required this.value});

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

class _MarketList extends StatelessWidget {
  const _MarketList({required this.title, required this.rows, required this.positive});

  final String title;
  final List<(String, String, double)> rows;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive ? context.finance.success : context.finance.danger;
    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final row in rows) ...[
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(row.$1, style: Theme.of(context).textTheme.labelLarge),
              subtitle: Text(row.$2),
              trailing: Text(
                '${row.$3 > 0 ? '+' : ''}${row.$3.toStringAsFixed(2)}%',
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.route});

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      onTap: () => Navigator.pushNamed(context, route),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18),
        ],
      ),
    );
  }
}
