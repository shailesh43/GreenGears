import 'package:flutter/material.dart';
import '../../network/api_models/car_request.dart';
// Custom
import '../widgets/form_detail_row.dart';
import '../widgets/form_text_field.dart';
import '../widgets/file_uploader.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/action_button_pair.dart';
import './base_modal.dart';

class PaymentDetailsModal extends StatelessWidget {
  final CarRequest request;

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
          // ES&A Data fields
          DetailRow(label: 'EMP ID', value: request.empId ?? 'NULL'),
          const SizedBox(height: 8),
          DetailRow(label: 'Request ID', value: request.requestId ?? 'NULL'),
          const SizedBox(height: 8),
          DetailRow(label: 'EMP name', value: request.employeeName ?? 'NULL'),
          const SizedBox(height: 8),
          DetailRow(label: 'Grade', value: request.grade ?? 'NULL'),
          const SizedBox(height: 8),
          DetailRow(label: 'Eligibility (RS)', value: request.eligibility.toString() ?? 'NULL'),
          const SizedBox(height: 8),
          DetailRow(label: 'EMI approval status', value: 'Approved'),
          const SizedBox(height: 16),

          // ES&A Input fields
          const FormTextField(label: 'PO Number', hint: 'Enter Purchase Order No', required: true,),
          const SizedBox(height: 16),
          const DatePickerField(label: 'PO Date'),
          const SizedBox(height: 16),
          const FormTextField(label: 'Disbursement Amount', hint: 'Enter Disbursement amount', required: true,),
          const SizedBox(height: 16),
          const DatePickerField(label: 'Payment Date'),
          const SizedBox(height: 16),
          const FormTextField(label: 'UTR', hint: 'Enter UTR code', required: true,),
          const SizedBox(height: 16),
          const FileUploadField(label: 'Upload Document'),
          const SizedBox(height: 16),
          const FormTextField(label: 'Comments', hint: 'Your Comments', maxLines: 3, required: true,),
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