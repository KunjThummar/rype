import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../core/services/import_service.dart';
import 'import_result_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_widgets.dart';

class ImportPortfolioScreen extends StatefulWidget {
  const ImportPortfolioScreen({super.key});

  @override
  State<ImportPortfolioScreen> createState() => _ImportPortfolioScreenState();
}

class _ImportPortfolioScreenState extends State<ImportPortfolioScreen> {
  PlatformFile? _pickedFile;
  bool _uploading = false;
  double _progress = 0;
  String? _error;

  Future<void> _pickFile() async {
    setState(() => _error = null);
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'xlsx'],
    );

    if (!mounted || file == null) return;

    if (file.path == null) {
      setState(() {
        _error = 'This file picker did not provide a local file path.';
      });
      return;
    }

    setState(() => _pickedFile = file);
  }

  Future<void> _upload() async {
    final selected = _pickedFile;
    if (selected?.path == null) {
      setState(() => _error = 'Choose a CSV or XLSX file first.');
      return;
    }

    setState(() {
      _uploading = true;
      _progress = 0;
      _error = null;
    });

    try {
      final record = await ImportService.uploadFile(
        File(selected!.path!),
        onSendProgress: (sent, total) {
          if (!mounted || total <= 0) return;
          setState(() => _progress = sent / total);
        },
      );

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImportResultScreen(importId: record.id),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Upload failed. Check the file format and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
          _progress = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Import Portfolio',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upload file', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'CSV and XLSX files are supported in this phase. Future broker sync and CAS PDF formats are reserved for later.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _uploading ? null : _pickFile,
                  icon: const Icon(Icons.attach_file_rounded),
                  label: const Text('Choose file'),
                ),
                if (_pickedFile != null) ...[
                  const SizedBox(height: 12),
                  _FileSummary(file: _pickedFile!),
                ],
                if (_uploading) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: _progress <= 0 ? null : _progress),
                  const SizedBox(height: 8),
                  Text(
                    '${(_progress * 100).toStringAsFixed(0)}% uploaded',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: context.finance.danger)),
                ],
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Import portfolio',
                  icon: Icons.cloud_upload_outlined,
                  loading: _uploading,
                  onPressed: _uploading ? null : _upload,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expected columns', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Text(
                  'Date, Symbol, Qty, Price',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'The parser will auto-detect matching headers such as Date, Buy Date, Symbol, Qty, Units, or Price variants.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SecondaryActionRow(
            icon: Icons.history_rounded,
            label: 'View import history',
            onPressed: () => Navigator.pushNamed(context, '/imports/history'),
          ),
        ],
      ),
    );
  }
}

class _FileSummary extends StatelessWidget {
  const _FileSummary({required this.file});

  final PlatformFile file;

  @override
  Widget build(BuildContext context) {
    final sizeKb = file.size / 1024;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.finance.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(file.name, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            '${file.extension?.toUpperCase() ?? 'FILE'} - ${sizeKb.toStringAsFixed(1)} KB',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class SecondaryActionRow extends StatelessWidget {
  const SecondaryActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
