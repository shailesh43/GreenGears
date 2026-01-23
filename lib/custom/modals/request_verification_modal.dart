import 'package:flutter/material.dart';

// Customs
import '../widgets/form_detail_row.dart';
import '../widgets/form_text_field.dart';
import '../widgets/file_uploader.dart';
import '../widgets/drop_down.dart';
import '../widgets/action_button_pair.dart';
import './base_modal.dart';

class RequestVerificationModal extends StatelessWidget {
  final Map<String, dynamic> request;

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
          DetailRow(label: 'Employee Name', value: 'Rahil Bopche'),
          DetailRow(label: 'Employee ID', value: '209164'),
          DetailRow(label: 'Grade',value: 'ME03'),
          DetailRow(label: 'Manufactured by', value: 'Honda'),
          DetailRow(label: 'Vehicle Type', value: 'Diesel'),
          DetailRow(label: 'Vehicle Model', value: 'fourseater'),
          DetailRow(label: 'Email', value: 'rahil.bopche@tatapower.com'),
          DetailRow(label: 'Color', value: 'white'),
          DetailRow(label: 'Comments by Employee', value: 'String'),
          const SizedBox(height: 24),

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