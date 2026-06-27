import 'package:flutter/material.dart';

import '../core/services/import_service.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_widgets.dart';

class ImportResultScreen extends StatefulWidget {
  const ImportResultScreen({super.key, required this.importId});

  final String importId;

  @override
  State<ImportResultScreen> createState() => _ImportResultScreenState();
}

class _ImportResultScreenState extends State<ImportResultScreen> {
  bool _loading = true;
  String? _error;
  ImportDetail? _detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final detail = await ImportService.getImport(widget.importId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Import details could not be loaded.';
        _loading = false;
      });
    }
  }

  Future<void> _deleteImport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete import'),
        content: const Text('This removes the import record and imported rows from the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ImportService.deleteImport(widget.importId);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Import Result',
      actions: [
        if (_detail != null)
          IconButton(
            tooltip: 'Delete import',
            onPressed: _deleteImport,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
      ],
      child: _loading
          ? const LoadingSkeleton()
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : _buildContent(_detail!),
    );
  }

  Widget _buildContent(ImportDetail detail) {
    final record = detail.importRecord;
    final summary = record.importSummary;
    final failureRows = summary.failedRows;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.fileName, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  '${record.status} - ${record.fileType} - ${record.totalRecords} rows',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricPill(label: 'Success', value: record.successRecords.toString(), color: context.finance.success),
                    _MetricPill(label: 'Failed', value: record.failedRecords.toString(), color: context.finance.danger),
                    _MetricPill(label: 'Symbols', value: summary.importedSymbols.length.toString(), color: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Imported symbols', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                if (summary.importedSymbols.isEmpty)
                  Text('No rows were imported.', style: Theme.of(context).textTheme.bodySmall)
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final symbol in summary.importedSymbols)
                        Chip(label: Text(symbol)),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Errors', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                if (summary.error != null)
                  Text(summary.error!, style: TextStyle(color: context.finance.danger))
                else if (failureRows.isEmpty)
                  Text('No row-level errors were reported.', style: Theme.of(context).textTheme.bodySmall)
                else
                  for (final failure in failureRows) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Icon(Icons.error_outline_rounded, color: context.finance.danger),
                      title: Text('Row ${failure.rowNumber}'),
                      subtitle: Text(failure.reason),
                    ),
                  ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Imported transactions', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                if (detail.transactions.isEmpty)
                  Text('Nothing was imported.', style: Theme.of(context).textTheme.bodySmall)
                else
                  for (final row in detail.transactions) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(row.symbol),
                      subtitle: Text('${row.quantity.toStringAsFixed(2)} @ ${formatCurrency(row.buyPrice)}'),
                      trailing: Text(row.buyDate.toLocal().toString().split(' ').first),
                    ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$label: $value', style: TextStyle(color: color)),
    );
  }
}
