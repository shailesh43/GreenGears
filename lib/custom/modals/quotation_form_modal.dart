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

  void _handleConfirm() {
    double baseCost = double.tryParse(_baseCostController.text) ?? 0;

    double sgstPercent = double.tryParse(_sgstController.text) ?? 0;
    double cgstPercent = double.tryParse(_cgstController.text) ?? 0;
    double cessPercent = double.tryParse(_cessController.text) ?? 0;

    double corpReg = double.tryParse(_corpRegController.text) ?? 0;

    double sgst = baseCost * (sgstPercent / 100);
    double cgst = baseCost * (cgstPercent / 100);
    double cess = baseCost * (cessPercent / 100);

    double total = baseCost + sgst + cgst + cess + corpReg;

    widget.onConfirm(total.toStringAsFixed(2));
    Navigator.pop(context);
  }

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
              ),
              const SizedBox(height: 20),

              // SGST and CGST Row
              Row(
                children: [
                  Expanded(
                    child: IntegerRangeField(
                      label: 'SGST (%)',
                      hint: 'Enter SGST %',
                      min: 1,
                      max: 30,
                      controller: _sgstController,
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
              ),
              const SizedBox(height: 20),

              // Corporate Registration Amount
              IntegerRangeField(
                label: 'Corporate Registration Amount (₹)',
                hint: 'Enter Corporate Amount in INR',
                min: 1,
                max: 100000000,
                controller: _corpRegController,
              ),
              const SizedBox(height: 20),

              // Miscellaneous
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
