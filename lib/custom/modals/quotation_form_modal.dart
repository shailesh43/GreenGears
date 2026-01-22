import 'package:flutter/material.dart';

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

  String _sgstValue = '10';
  String _cgstValue = '5';
  String _cessValue = '10';

  @override
  void dispose() {
    _baseCostController.dispose();
    _corpRegController.dispose();
    _miscController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    // Calculate total amount
    double baseCost = double.tryParse(_baseCostController.text) ?? 0;
    double sgst = baseCost * (double.parse(_sgstValue) / 100);
    double cgst = baseCost * (double.parse(_cgstValue) / 100);
    double cess = baseCost * (double.parse(_cessValue) / 100);
    double corpReg = double.tryParse(_corpRegController.text) ?? 0;

    double total = baseCost + sgst + cgst + cess + corpReg;

    widget.onConfirm('₹${total.toStringAsFixed(2)}');
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
              const Text(
                'Quotation Form Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 24),

              // Base Cost
              _buildModalLabel('Base Cost (₹)', required: true),
              const SizedBox(height: 8),
              _buildModalTextField(
                controller: _baseCostController,
                hint: '40,500',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // SGST and CGST Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildModalLabel('SGST (%)', required: true),
                        const SizedBox(height: 8),
                        _buildModalDropdown(
                          value: _sgstValue,
                          onChanged: (value) {
                            setState(() {
                              _sgstValue = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildModalLabel('CGST (%)', required: true),
                        const SizedBox(height: 8),
                        _buildModalDropdown(
                          value: _cgstValue,
                          onChanged: (value) {
                            setState(() {
                              _cgstValue = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // CESS Percentage
              _buildModalLabel('CESS Percentage', required: true),
              const SizedBox(height: 8),
              _buildModalDropdown(
                value: _cessValue,
                onChanged: (value) {
                  setState(() {
                    _cessValue = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Corporate Registration Amount
              _buildModalLabel('Corporate Registration Amount (₹)', required: true),
              const SizedBox(height: 8),
              _buildModalTextField(
                controller: _corpRegController,
                hint: '65,300',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Miscellaneous
              _buildModalLabel('Miscellaneous'),
              const SizedBox(height: 8),
              _buildModalTextField(
                controller: _miscController,
                hint: 'Enter Miscellaneous',
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

  Widget _buildModalLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 13,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _buildModalTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 15,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0EA5E9)),
        ),
      ),
    );
  }

  Widget _buildModalDropdown({
    required String value,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: ['5', '10', '15', '20'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
