import 'package:flutter/material.dart';

import '../widgets/form_text_field.dart';
import '../widgets/integer_range_field.dart';

class QuotationFormModal extends StatefulWidget {
  final Function(String) onConfirm;

  const QuotationFormModal({
    super.key,
    required this.onConfirm,
  });

  @override
  State<QuotationFormModal> createState() => _QuotationFormModalState();
}

class _QuotationFormModalState extends State<QuotationFormModal> {
  final TextEditingController _baseCostController = TextEditingController();
  final TextEditingController _corpRegController = TextEditingController();
  final TextEditingController _miscController = TextEditingController();
  final TextEditingController _sgstController = TextEditingController();
  final TextEditingController _cgstController = TextEditingController();
  final TextEditingController _cessController = TextEditingController();

  // Inline error texts for required fields
  String? _baseCostErrorText;
  String? _sgstErrorText;
  String? _cgstErrorText;
  String? _cessErrorText;
  String? _corpRegErrorText;

  @override
  void initState() {
    super.initState();

    _baseCostController.addListener(() {
      if (_baseCostErrorText != null &&
          _baseCostController.text.trim().isNotEmpty) {
        setState(() => _baseCostErrorText = null);
      }
    });

    _sgstController.addListener(() {
      if (_sgstErrorText != null && _sgstController.text.trim().isNotEmpty) {
        setState(() => _sgstErrorText = null);
      }
    });

    _cgstController.addListener(() {
      if (_cgstErrorText != null && _cgstController.text.trim().isNotEmpty) {
        setState(() => _cgstErrorText = null);
      }
    });

    _cessController.addListener(() {
      if (_cessErrorText != null && _cessController.text.trim().isNotEmpty) {
        setState(() => _cessErrorText = null);
      }
    });

    _corpRegController.addListener(() {
      if (_corpRegErrorText != null &&
          _corpRegController.text.trim().isNotEmpty) {
        setState(() => _corpRegErrorText = null);
      }
    });
  }

  @override
  void dispose() {
    _baseCostController.dispose();
    _corpRegController.dispose();
    _miscController.dispose();
    _sgstController.dispose();
    _cgstController.dispose();
    _cessController.dispose();
    super.dispose();
  }

  // ==================== VALIDATION ====================

  bool _validate() {
    bool isValid = true;

    setState(() {
      _baseCostErrorText =
      _baseCostController.text.trim().isEmpty ? 'Required' : null;
      _sgstErrorText =
      _sgstController.text.trim().isEmpty ? 'Required' : null;
      _cgstErrorText =
      _cgstController.text.trim().isEmpty ? 'Required' : null;
      _cessErrorText =
      _cessController.text.trim().isEmpty ? 'Required' : null;
      _corpRegErrorText =
      _corpRegController.text.trim().isEmpty ? 'Required' : null;

      if (_baseCostController.text.trim().isEmpty ||
          _sgstController.text.trim().isEmpty ||
          _cgstController.text.trim().isEmpty ||
          _cessController.text.trim().isEmpty ||
          _corpRegController.text.trim().isEmpty) {
        isValid = false;
      }
    });

    return isValid;
  }

  // ==================== CONFIRM HANDLER ====================

  void _handleConfirm() {
    if (!_validate()) return;

    final double baseCost = double.tryParse(_baseCostController.text) ?? 0;
    final double sgstPercent = double.tryParse(_sgstController.text) ?? 0;
    final double cgstPercent = double.tryParse(_cgstController.text) ?? 0;
    final double cessPercent = double.tryParse(_cessController.text) ?? 0;
    final double corpReg = double.tryParse(_corpRegController.text) ?? 0;

    final double sgst = baseCost * (sgstPercent / 100);
    final double cgst = baseCost * (cgstPercent / 100);
    final double cess = baseCost * (cessPercent / 100);

    final double total = baseCost + sgst + cgst + cess + corpReg;

    widget.onConfirm(total.toStringAsFixed(2));
    Navigator.pop(context);
  }

  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              /// HEADER WITH CLOSE ICON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quotation Form Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: -0.4,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Base Cost
              IntegerRangeField(
                label: 'Base Cost (₹)',
                hint: 'Enter Base cost in INR',
                min: 18,
                max: 60,
                controller: _baseCostController,
                errorText: _baseCostErrorText,
              ),
              const SizedBox(height: 20),

              // SGST and CGST Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: IntegerRangeField(
                      label: 'SGST (%)',
                      hint: 'Enter SGST %',
                      min: 1,
                      max: 30,
                      controller: _sgstController,
                      errorText: _sgstErrorText,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: IntegerRangeField(
                      label: 'CGST (%)',
                      hint: 'Enter CGST %',
                      min: 1,
                      max: 30,
                      controller: _cgstController,
                      errorText: _cgstErrorText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // CESS Percentage
              IntegerRangeField(
                label: 'CESS Percentage',
                hint: 'Enter CESS %',
                min: 1,
                max: 30,
                controller: _cessController,
                errorText: _cessErrorText,
              ),
              const SizedBox(height: 20),

              // Corporate Registration Amount
              IntegerRangeField(
                label: 'Corporate Registration Amount (₹)',
                hint: 'Enter Corporate Amount in INR',
                min: 1,
                max: 100000000,
                controller: _corpRegController,
                errorText: _corpRegErrorText,
              ),
              const SizedBox(height: 20),

              // Miscellaneous (not required)
              const SizedBox(height: 8),
              FormTextField(
                label: 'Miscellaneous',
                hint: 'Enter Miscellaneous',
                controller: _miscController,
              ),
              const SizedBox(height: 32),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
}