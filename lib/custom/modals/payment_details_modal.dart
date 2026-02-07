import 'package:flutter/material.dart';
import '../../network/api_models/car_request.dart';
// Custom
import '../widgets/form_detail_row.dart';
import '../widgets/form_text_field.dart';
import '../widgets/file_uploader.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/action_button_pair.dart';
import './base_modal.dart';

import '../../network/api_client.dart';

class PaymentDetailsModal extends StatefulWidget {
  final CarRequest request;
  PaymentDetailsModal({
    super.key,
    required this.request
  });

  @override
  State<PaymentDetailsModal> createState() => _PaymentDetailsModalState();
}

class _PaymentDetailsModalState extends State<PaymentDetailsModal> {
  final ApiClient _client = ApiClient();
  final _commentsCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      request: widget.request,
      title: 'Payment Details',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ES&A Data fields
          DetailRow(label: 'EMP ID', value: widget.request.empId ?? 'NULL'),
          const SizedBox(height: 8),
          DetailRow(label: 'Request ID', value: widget.request.requestId ?? 'NULL'),
          const SizedBox(height: 8),
          DetailRow(label: 'EMP name', value: widget.request.employeeName ?? 'NULL'),
          const SizedBox(height: 8),
          DetailRow(label: 'Grade', value: widget.request.grade ?? 'NULL'),
          const SizedBox(height: 8),
          DetailRow(label: 'Eligibility (RS)', value: widget.request.eligibility.toString() ?? 'NULL'),
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
          FormTextField(label: 'Comments', hint: 'Your Comments', maxLines: 3, required: true, controller: _commentsCtrl,),
          const SizedBox(height: 24),
        ],
      ),
      bottom: ActionButtonPair(
        primaryText: 'Approve',
        secondaryText: 'Reject',
        primaryMessage: 'Request Approved',
        secondaryMessage: 'Request Rejected',
        onPrimaryAction: () => _handleApprove(),
        onSecondaryAction: () => _handleReject(),
      ),
    );
  }

  Future<void> _handleApprove() async {
    final request = widget.request;
    final requestId = request.requestId;
    final empId = request.empId;

    if (requestId == null || empId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing request or employee details')),
      );
      return;
    }

    try {
      final response = await _client.submitByEsnaPayment(
        requestId: requestId,
        empId: empId,
        commentsAssignedToEsna: _commentsCtrl.text.trim(),
      );

      Navigator.pop(context, response); // success close
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _handleReject() async {
    final request = widget.request;
    final requestId = request.requestId;
    final empId = request.empId;

    if (requestId == null || empId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing request or employee details')),
      );
      return;
    }

    try {
      final response = await _client.decrementStageOnReject(
        requestId: requestId,
        empId: empId,
      );

      Navigator.pop(context, response); // success close
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

}