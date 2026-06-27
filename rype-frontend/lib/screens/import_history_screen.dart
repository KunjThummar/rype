import 'package:flutter/material.dart';

import '../core/services/import_service.dart';
import 'import_result_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_widgets.dart';

class ImportHistoryScreen extends StatefulWidget {
  const ImportHistoryScreen({super.key});

  @override
  State<ImportHistoryScreen> createState() => _ImportHistoryScreenState();
}

class _ImportHistoryScreenState extends State<ImportHistoryScreen> {
  bool _loading = true;
  String? _error;
  List<PortfolioImportRecord> _records = [];

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
      final records = await ImportService.getHistory();
      if (!mounted) return;
      setState(() {
        _records = records;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Import history could not be loaded right now.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Import History',
      child: _loading
          ? const LoadingSkeleton()
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (_records.isEmpty)
                        const EmptyState(
                          icon: Icons.history_rounded,
                          title: 'No imports yet',
                          message: 'Uploaded files will appear here with their status and counts.',
                        )
                      else
                        for (final record in _records) ...[
                          _ImportHistoryTile(
                            record: record,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ImportResultScreen(
                                  importId: record.id,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                    ],
                  ),
                ),
    );
  }
}

class _ImportHistoryTile extends StatelessWidget {
  const _ImportHistoryTile({
    required this.record,
    required this.onTap,
  });

  final PortfolioImportRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFailure = record.status == 'FAILED';
    final color = isFailure ? context.finance.danger : context.finance.success;

    return FinanceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(record.fileName, style: Theme.of(context).textTheme.titleMedium),
              ),
              Text(
                record.status,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${record.fileType} - ${record.uploadedAt.toLocal()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _CountChip(label: 'Total', value: record.totalRecords.toString()),
              _CountChip(label: 'Success', value: record.successRecords.toString()),
              _CountChip(label: 'Failed', value: record.failedRecords.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.finance.pageSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$label: $value'),
    );
  }
}
