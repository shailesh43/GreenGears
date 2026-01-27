import 'package:flutter/material.dart';
import '../../network/api_models/car_request.dart';
// Customs
import '../widgets/form_detail_row.dart';
import '../widgets/form_text_field.dart';
import '../widgets/file_uploader.dart';
import '../widgets/drop_down.dart';
import '../widgets/action_button_pair.dart';
import './base_modal.dart';

class RequestVerificationModal extends StatelessWidget {
  final CarRequest request;

  const RequestVerificationModal({
    super.key,
    required this.request
  });

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      request: request,
      title: 'Request Verification',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ES&A Info fields
          DetailRow(label: 'Employee Name', value: request.employeeName ?? 'NULL'),
          DetailRow(label: 'Employee ID', value: request.empId ?? 'NULL'),
          DetailRow(label: 'Grade',value: request.grade ?? 'NULL'),
          DetailRow(label: 'Manufactured by', value: request.manufacturer ?? 'NULL'),
          DetailRow(label: 'Vehicle Type', value: request.vehicleType ?? 'NULL'),
          DetailRow(label: 'Vehicle Model', value: request.carModel ?? 'NULL'),
          DetailRow(label: 'Email', value: request.email ?? 'NULL'),
          DetailRow(label: 'Color', value: request.colorChoice ?? 'NULL'),
          // DetailRow(label: 'Comments by Employee', value: 'Approved' ?? 'NULL'),
          const SizedBox(height: 24),

          // ES&A Input fields
          const FormTextField(label: 'ES&A Comments', maxLines: 3, required: true,),
          const SizedBox(height: 16),
          _buildLabel("Upload Document"),
          FileUploadField(
            label: 'File Type Allowed: .pdf/.txt/.docx',
            allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],
          ),
          const SizedBox(height: 16),
          DropdownField(
            label: 'View Document',
            hints: 'Select Document',
            items: ['Document 1', 'Document 2', 'Document 3'],
          ),
          const SizedBox(height: 24),
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
}