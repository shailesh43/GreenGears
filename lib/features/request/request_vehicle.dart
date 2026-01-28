import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../custom/widgets/file_uploader.dart';
import '../../custom/modals/quotation_form_modal.dart';

import '../../custom/widgets/form_text_field.dart';
import '../../custom/widgets/file_uploader.dart';
import '../../custom/widgets/form_detail_row.dart';

class VehicleRequestPage extends StatefulWidget {
  const VehicleRequestPage({super.key});

  @override
  State<VehicleRequestPage> createState() => _VehicleRequestPageState();
}

class _VehicleRequestPageState extends State<VehicleRequestPage> {
  final _formKey = GlobalKey<FormState>();
  String quotationAmountModalResult = '0';

  void _showQuotationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuotationFormModal(
        onConfirm: (amount) {
          setState(() {
            quotationAmountModalResult = amount;
          });
        },
      ),
    );
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
          'Create Request',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
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
                    FormTextField(
                      label: 'Manufacturer',
                      hint: 'Enter Manufacturer',
                      required: true,
                    ),
                    const SizedBox(height: 20),

                    // Vehicle Model
                    FormTextField(
                      label: 'Vehicle Model',
                      hint: 'Enter Vehicle Model',
                      required: true,
                    ),
                    const SizedBox(height: 20),

                    // Colour
                    FormTextField(
                      label: 'Colour',
                      hint: 'Enter Vehicle colour',
                    ),
                    const SizedBox(height: 20),

                    // Vehicle Type
                    FormTextField(
                      label: 'Vehicle Type',
                      hint: 'Select Vehicle Type',
                    ),
                    const SizedBox(height: 20),

                    // Comments
                    FormTextField(
                      label: 'Comments',
                      hint: 'Your Comments',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Upload Document

                    FileUploadField(label: 'Upload Quotation Document', allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],),
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
                    DetailRow(label: 'Quotation Amount (₹)', value: '₹ $quotationAmountModalResult'),
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
}
