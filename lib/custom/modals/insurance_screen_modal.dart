import 'package:flutter/material.dart';

import '../widgets/action_button_pair.dart';
import '../widgets/request_card.dart';
import '../widgets/form_detail_row.dart';
import '../widgets/form_text_field.dart';
import '../widgets/file_uploader.dart';
import '../widgets/drop_down.dart';
import '../../network/api_models/car_request.dart';

class InsuranceScreenModal extends StatefulWidget {
  final CarRequest request;

  const InsuranceScreenModal({
    super.key,
    required this.request
  });

  @override
  State<InsuranceScreenModal> createState() => _InsuranceScreenModalState();
}

class _InsuranceScreenModalState extends State<InsuranceScreenModal> {
  String? selectedDocumentName;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.request.employeeName ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40)
                  ],
                ),
              ),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(widget.request),
                      const SizedBox(height: 24),
                      DetailRow(
                          label: 'Vehicle Model',
                          value: widget.request.carModel ?? 'NULL'),
                      DetailRow(
                          label: 'Manufactured by',
                          value: widget.request.manufacturer ?? 'NULL'),
                      DetailRow(
                          label: 'Color', value: widget.request.colorChoice ?? 'NULL'),
                      DetailRow(
                          label: 'Employee Name',
                          value: widget.request.employeeName ?? 'NULL'),
                      DetailRow(
                          label: 'Employee ID', value: widget.request.empId ?? 'NULL'),
                      DetailRow(
                          label: 'Phone', value: widget.request.contact ?? 'NULL'),
                      DetailRow(
                          label: 'Company', value: widget.request.company ?? 'NULL'),
                      DetailRow(
                          label: 'Grade', value: widget.request.grade ?? 'NULL'),
                      DetailRow(
                          label: 'Email', value: widget.request.email ?? 'NULL'),
                      DetailRow(
                          label: 'Eligibility',
                          value: widget.request.eligibility.toString() ?? 'NULL'),
                      DetailRow(
                          label: 'Quotation Amount',
                          value: widget.request.totalEmi.toString() ?? 'NULL'),
                      const SizedBox(height: 24),

                      // Base Insurance
                      FormTextField(
                          label: 'Base Insurance',
                          hint: 'Enter Base Insurance',
                          required: true
                      ),
                      const SizedBox(height: 16),

                      // Addon Cover
                      FormTextField(
                          label: 'Addon Cover',
                          hint: 'Enter Addon Cover',
                          required: true
                      ),
                      const SizedBox(height: 16),

                      // Addon Saphire Plus
                      FormTextField(
                          label: 'Addon Saphire Plus',
                          hint: 'Enter Addon Saphire Plus',
                          required: true
                      ),
                      const SizedBox(height: 16),

                      // Upload Files
                      const FileUploadField(label: 'Upload Document'),
                      const SizedBox(height: 16),

                      // Comments
                      FormTextField(
                        label: 'Comments',
                        hint: 'Enter Comments',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // View Document Dropdown
                      DropdownField(
                        label: 'View Document',
                        hints: 'Select Document',
                        items: ['User Quotation Document'],
                        onChanged: (value) {
                          setState(() {
                            selectedDocumentName = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      ActionButtonPair(
                        primaryText: 'Approve',
                        secondaryText: 'Reject',
                        primaryMessage: 'Request Approved',
                        secondaryMessage: 'Request Rejected',
                        onPrimaryAction: () {
                          // Handle approve logic
                        },
                        onSecondaryAction: () {
                          // Handle reject logic
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(CarRequest request) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Request ID',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Text(
          widget.request.requestId ?? 'CAR2025242',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

}