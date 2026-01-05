import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VehicleRequestPage extends StatefulWidget {
  const VehicleRequestPage({super.key});

  @override
  State<VehicleRequestPage> createState() => _VehicleRequestPageState();
}

class _VehicleRequestPageState extends State<VehicleRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _colourController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  final TextEditingController _quotationAmountController = TextEditingController();

  String? _selectedVehicleType;
  String? _uploadedFileName;

  @override
  void dispose() {
    _manufacturerController.dispose();
    _modelController.dispose();
    _colourController.dispose();
    _commentsController.dispose();
    _quotationAmountController.dispose();
    super.dispose();
  }

  void _showQuotationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuotationFormModal(
        onConfirm: (amount) {
          setState(() {
            _quotationAmountController.text = amount;
          });
        },
      ),
    );
  }

  void _handleFileUpload() {
    // Simulate file upload
    setState(() {
      _uploadedFileName = 'filename.pdf';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicle Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2ECC71),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Manufacturer
                    _buildLabel('Manufactured by', required: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _manufacturerController,
                      hint: 'Enter Manufacturer',
                    ),
                    const SizedBox(height: 20),

                    // Vehicle Model
                    _buildLabel('Vehicle Model', required: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _modelController,
                      hint: 'Enter Model',
                    ),
                    const SizedBox(height: 20),

                    // Colour
                    _buildLabel('Colour', required: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _colourController,
                      hint: 'Enter Vehicle colour',
                    ),
                    const SizedBox(height: 20),

                    // Vehicle Type
                    _buildLabel('Vehicle Type', required: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _colourController,
                      hint: 'Select Vehicle Type',
                    ),
                    const SizedBox(height: 20),

                    // Comments
                    _buildLabel('Comments', required: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _commentsController,
                      hint: 'Your Comment',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Upload Document
                    _buildLabel('Upload Quotation Document', required: true),
                    Text(
                      'in .pdf/.txt/.docx',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildUploadField(),
                    const SizedBox(height: 24),

                    // Calculate Quotation Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _showQuotationModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C2C2C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Calculate Quotation Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quotation Amount Display
                    _buildLabel('Quotation Amount (₹)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _quotationAmountController,
                      hint: '₹3769.40',
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle submit
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 15,
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
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
          borderSide: const BorderSide(color: Color(0xFF2ECC71)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          value ?? hint,
          style: TextStyle(
            color: value == null ? Colors.grey[400] : Colors.black,
            fontSize: 15,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Show vehicle type selection
        },
      ),
    );
  }

  Widget _buildUploadField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: _handleFileUpload,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.upload_outlined, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Upload',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _uploadedFileName ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== QUOTATION FORM MODAL ====================
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
                  fontWeight: FontWeight.w700,
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
