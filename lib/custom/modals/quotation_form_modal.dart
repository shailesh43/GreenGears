import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../network/api_client.dart';
import '../../constants/local_prefs.dart';
import '../widgets/form_text_field.dart';
import '../widgets/integer_range_field.dart';
import 'package:greengears/main.dart';

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
  final ApiClient _client = globalApiClient;

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

  bool _isSubmitting = false;

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

    if (!isValid) {
      _showValidationToast('Please fill all required fields');
    }

    return isValid;
  }

  void _showValidationToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 3,
      backgroundColor: const Color(0xFFFFE3E3),
      textColor: const Color(0xFFFA6262),
      fontSize: 14.0,
    );
  }

  // ==================== API CALL ====================

  Future<void> _handleConfirm() async {
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final empId = await LocalPrefs.getEmpCode();

      if (empId == null || empId.isEmpty) {
        _showValidationToast('Employee ID not found');
        setState(() => _isSubmitting = false);
        return;
      }

      // Convert to proper types - INT for amounts, DOUBLE for percentages
      final String baseCost = _baseCostController.text.trim();
      final String sgstPercentage = _sgstController.text.trim();
      final String cgstPercentage = _cgstController.text.trim();
      final String cessPercentage = _cessController.text.trim();
      final String registrationAmount = _corpRegController.text.trim();
      final String additionalAccessories = _miscController.text.trim().isEmpty
          ? '0'
          : _miscController.text.trim();

      // Call API
      final response = await _client.updateVehicleQuotation(
        baseCost: baseCost,
        sgstPercentage: sgstPercentage,
        cgstPercentage: cgstPercentage,
        cessPercentage: cessPercentage,
        registrationAmount: registrationAmount,
        additionalAccessories: additionalAccessories,
        empId: empId,
      );

      // Extract final quotation amount from response
      final finalQuotationAmount = response.vehicleQuotation?.finalQuotationAmount ?? '0';

      // Pass the result back
      widget.onConfirm(finalQuotationAmount);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error updating vehicle quotation: $e');
      _showValidationToast('Failed to calculate quotation. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Base Cost (Integer)
              IntegerRangeField(
                label: 'Base Cost (',
                hint: 'Enter Base cost in INR',
                min: 18,
                max: 100000000,
                controller: _baseCostController,
                errorText: _baseCostErrorText,
                isInteger: true,
                required: true,
              ),
              const SizedBox(height: 20),

              // SGST and CGST Row (Decimal)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: IntegerRangeField(
                      label: 'SGST (%) *',
                      hint: 'Enter SGST %',
                      min: 1,
                      max: 30,
                      controller: _sgstController,
                      errorText: _sgstErrorText,
                      isInteger: false,
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: IntegerRangeField(
                      label: 'CGST (%) *',
                      hint: 'Enter CGST %',
                      min: 1,
                      max: 30,
                      controller: _cgstController,
                      errorText: _cgstErrorText,
                      isInteger: false,
                      required: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // CESS Percentage (Decimal)
              IntegerRangeField(
                label: 'CESS Percentage *',
                hint: 'Enter CESS %',
                min: 1,
                max: 30,
                controller: _cessController,
                errorText: _cessErrorText,
                isInteger: false,
                required: true,
              ),
              const SizedBox(height: 20),

              // Corporate Registration Amount (Integer)
              IntegerRangeField(
                label: 'Corporate Registration Amount (₹) *',
                hint: 'Enter Corporate Amount in INR',
                min: 1,
                max: 100000000,
                controller: _corpRegController,
                errorText: _corpRegErrorText,
                isInteger: true,
                required: true,
              ),
              const SizedBox(height: 20),

              // Miscellaneous (Integer, not required)
              IntegerRangeField(
                label: 'Miscellaneous',
                hint: 'Enter Miscellaneous',
                min: 0,
                max: 100000000,
                controller: _miscController,
                isInteger: true,
                required: false,
              ),
              const SizedBox(height: 32),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
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