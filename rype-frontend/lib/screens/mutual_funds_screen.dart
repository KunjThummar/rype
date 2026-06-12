import 'package:flutter/material.dart';

import '../core/services/mutual_fund_service.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_widgets.dart';

class MutualFundsScreen extends StatefulWidget {
  const MutualFundsScreen({super.key});

  @override
  State<MutualFundsScreen> createState() => _MutualFundsScreenState();
}

class _MutualFundsScreenState extends State<MutualFundsScreen> {
  List funds = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadFunds();
  }

  Future<void> loadFunds() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await MutualFundService().getFunds();
      if (!mounted) return;
      setState(() {
        funds = response.data is List ? response.data : [];
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Mutual funds could not be loaded. Please try again.';
        loading = false;
      });
    }
  }

  Future<void> deleteFund(String id) async {
    await MutualFundService().deleteFund(id);
    loadFunds();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Mutual Funds',
      child: loading
          ? const LoadingSkeleton()
          : error != null
              ? ErrorState(message: error!, onRetry: loadFunds)
              : funds.isEmpty
                  ? const EmptyState(
                      icon: Icons.account_balance_rounded,
                      title: 'No mutual funds yet',
                      message: 'Add a fund to view NAV, units, and portfolio value.',
                    )
                  : RefreshIndicator(
                      onRefresh: loadFunds,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: funds.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final fund = funds[index];
                          final units = asDouble(fund['units']);
                          final purchaseNav = asDouble(fund['purchaseNav']);
                          final currentNav = asDouble(fund['currentNav']);
                          final pnl = (currentNav - purchaseNav) * units;
                          final color = pnl >= 0 ? context.finance.success : context.finance.danger;

                          return FinanceCard(
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.account_balance_rounded, color: Theme.of(context).colorScheme.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(asText(fund['fundName']), maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 4),
                                      Text('${units.toStringAsFixed(2)} units | NAV ${formatCurrency(currentNav)}', style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(formatCurrency(pnl), style: TextStyle(color: color, fontWeight: FontWeight.w800)),
                                    IconButton(
                                      tooltip: 'Delete',
                                      onPressed: () => deleteFund(asText(fund['_id'])),
                                      icon: Icon(Icons.delete_outline_rounded, color: context.finance.danger),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add-mutual-fund');
          loadFunds();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Fund'),
      ),
    );
  }
}
