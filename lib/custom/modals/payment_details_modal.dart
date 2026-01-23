import 'package:flutter/material.dart';

// Custom
import '../widgets/form_detail_row.dart';
import '../widgets/form_text_field.dart';
import '../widgets/file_uploader.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/action_button_pair.dart';
import './base_modal.dart';

class PaymentDetailsModal extends StatelessWidget {
  final Map<String, dynamic> request;

  const PaymentDetailsModal({
    super.key,
    required this.request
  });

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      request: request,
      title: 'Payment Details',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(label: 'EMP ID', value: '208829'),
          const SizedBox(height: 8),
          DetailRow(label: 'Request ID', value: 'CAR2025241'),
          const SizedBox(height: 8),
          DetailRow(label: 'EMP name', value: 'Rahil Bopche'),
          const SizedBox(height: 8),
          DetailRow(label: 'Grade', value: 'ME03'),
          const SizedBox(height: 8),
          DetailRow(label: 'Eligibility (RS)', value: '50,000'),
          const SizedBox(height: 8),
          DetailRow(label: 'EMI approval comments', value: 'Approved'),
          const SizedBox(height: 16),

          const FormTextField(label: 'PO Number', required: true,),
          const SizedBox(height: 16),
          const DatePickerField(label: 'PO Date'),
          const SizedBox(height: 16),
          const FormTextField(label: 'Disbursement Amount', required: true,),
          const SizedBox(height: 16),
          const DatePickerField(label: 'Payment Date'),
          const SizedBox(height: 16),
          const FormTextField(label: 'UTR', required: true,),
          const SizedBox(height: 16),
          const FileUploadField(label: 'Upload Document'),
          const SizedBox(height: 16),
          const FormTextField(label: 'Comments', maxLines: 3, required: true,),
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
}