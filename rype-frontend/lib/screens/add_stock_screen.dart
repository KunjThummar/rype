import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/services/stock_service.dart';

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
          const SnackBar(
            content: Text('Stock added successfully!'),
            backgroundColor: Color(0xFF00E5A0),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (msg.startsWith('Exception: ')) msg = msg.replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E1A), Color(0xFF0F2027), Color(0xFF203A43)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── App Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Add Stock',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildField(
                          controller: _stockNameController,
                          label: 'Stock Name',
                          hint: 'e.g. Reliance Industries',
                          icon: Icons.business_outlined,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Enter stock name' : null,
                        ),
                        _buildField(
                          controller: _symbolController,
                          label: 'Ticker Symbol',
                          hint: 'e.g. RELIANCE',
                          icon: Icons.tag_rounded,
                          inputFormatters: [UpperCaseTextFormatter()],
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Enter ticker symbol' : null,
                        ),
                        _buildField(
                          controller: _quantityController,
                          label: 'Quantity',
                          hint: 'e.g. 10',
                          icon: Icons.format_list_numbered_rounded,
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
                        _buildField(
                          controller: _buyPriceController,
                          label: 'Buy Price (₹)',
                          hint: 'e.g. 2500.00',
                          icon: Icons.currency_rupee_rounded,
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
                        _buildField(
                          controller: _currentPriceController,
                          label: 'Current Price (₹)',
                          hint: 'e.g. 2750.00',
                          icon: Icons.price_change_outlined,
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
                        const SizedBox(height: 12),

                        // ── Live P&L Preview ──
                        _buildPreview(),
                        const SizedBox(height: 28),

                        // ── Save Button ──
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyanAccent,
                              foregroundColor: const Color(0xFF0A0E1A),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF0A0E1A)),
                                    ),
                                  )
                                : const Text(
                                    'Add to Portfolio',
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
          prefixIcon: Icon(icon, color: Colors.cyanAccent, size: 20),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.04),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final qty = int.tryParse(_quantityController.text) ?? 0;
    final buy = double.tryParse(_buyPriceController.text) ?? 0.0;
    final curr = double.tryParse(_currentPriceController.text) ?? 0.0;

    if (qty == 0 && buy == 0.0) return const SizedBox.shrink();

    final invested = qty * buy;
    final currentVal = qty * curr;
    final pl = currentVal - invested;
    final plPct = invested > 0 ? (pl / invested * 100) : 0.0;
    final isProfit = pl >= 0;
    final profitColor = isProfit ? const Color(0xFF00E5A0) : const Color(0xFFFF5252);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview',
            style: TextStyle(
                color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _previewItem('Invested', '₹${invested.toStringAsFixed(2)}', Colors.white70),
              _previewItem(
                  'Current Value', '₹${currentVal.toStringAsFixed(2)}', Colors.white70),
              _previewItem(
                'P&L',
                '${isProfit ? '+' : ''}₹${pl.toStringAsFixed(2)} (${isProfit ? '+' : ''}${plPct.toStringAsFixed(1)}%)',
                profitColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
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
