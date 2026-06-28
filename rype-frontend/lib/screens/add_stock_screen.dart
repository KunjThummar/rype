import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/services/stock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_widgets.dart';

class AddStockScreen extends StatefulWidget {
  const AddStockScreen({super.key});

  @override
  State<AddStockScreen> createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stockNameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _currentPriceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _stockNameController.dispose();
    _symbolController.dispose();
    _quantityController.dispose();
    _buyPriceController.dispose();
    _currentPriceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await StockService.createStock({
        'stockName': _stockNameController.text.trim(),
        'symbol': _symbolController.text.trim().toUpperCase(),
        'quantity': int.parse(_quantityController.text.trim()),
        'buyPrice': double.parse(_buyPriceController.text.trim()),
        'currentPrice': double.parse(_currentPriceController.text.trim()),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (msg.startsWith('Exception: ')) msg = msg.replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Add Stock',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Form card ──
              FinanceCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _stockNameController,
                      label: 'Stock Name',
                      hint: 'e.g. Reliance Industries',
                      prefixIcon: Icons.business_outlined,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Enter stock name' : null,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _symbolController,
                      label: 'Ticker Symbol',
                      hint: 'e.g. RELIANCE',
                      prefixIcon: Icons.tag_rounded,
                      inputFormatters: [UpperCaseTextFormatter()],
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Enter ticker symbol' : null,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _quantityController,
                      label: 'Quantity',
                      hint: 'e.g. 10',
                      prefixIcon: Icons.format_list_numbered_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter quantity';
                        if (int.tryParse(v.trim()) == null || int.parse(v.trim()) <= 0) {
                          return 'Enter a valid quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _buyPriceController,
                      label: 'Buy Price (₹)',
                      hint: 'e.g. 2500.00',
                      prefixIcon: Icons.currency_rupee_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter buy price';
                        if (double.tryParse(v.trim()) == null) return 'Invalid price';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _currentPriceController,
                      label: 'Current Price (₹)',
                      hint: 'e.g. 2750.00',
                      prefixIcon: Icons.price_change_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter current price';
                        if (double.tryParse(v.trim()) == null) return 'Invalid price';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Live P&L Preview ──
              _buildPreview(context),

              const SizedBox(height: 24),

              // ── Save Button ──
              PrimaryButton(
                label: 'Add to Portfolio',
                icon: Icons.add_rounded,
                loading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    final qty = int.tryParse(_quantityController.text) ?? 0;
    final buy = double.tryParse(_buyPriceController.text) ?? 0.0;
    final curr = double.tryParse(_currentPriceController.text) ?? 0.0;

    if (qty == 0 && buy == 0.0) return const SizedBox.shrink();

    final invested = qty * buy;
    final currentVal = qty * curr;
    final pl = currentVal - invested;
    final plPct = invested > 0 ? (pl / invested * 100) : 0.0;
    final isProfit = pl >= 0;
    final profitColor = isProfit ? context.finance.success : context.finance.danger;

    return FinanceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Preview',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _PreviewItem(
                label: 'Invested',
                value: formatCurrency(invested),
                color: Theme.of(context).textTheme.labelLarge!.color!,
              ),
              _PreviewItem(
                label: 'Current Value',
                value: formatCurrency(currentVal),
                color: Theme.of(context).textTheme.labelLarge!.color!,
              ),
              _PreviewItem(
                label: 'P&L',
                value:
                    '${isProfit ? '+' : ''}${formatCurrency(pl)} (${isProfit ? '+' : ''}${plPct.toStringAsFixed(1)}%)',
                color: profitColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewItem extends StatelessWidget {
  const _PreviewItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
