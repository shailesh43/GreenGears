import 'package:flutter/material.dart';
import '../../network/api_models/car_request.dart';
// Customs
import '../widgets/form_detail_row.dart';
import '../widgets/form_text_field.dart';
import '../widgets/file_uploader.dart';
import '../widgets/drop_down.dart';
import '../widgets/action_button_pair.dart';
import './base_modal.dart';

import '../../network/api_client.dart';

class RequestVerificationModal extends StatefulWidget {
  final CarRequest request;

  RequestVerificationModal({
    super.key,
    required this.request
  });

  @override
  State<RequestVerificationModal> createState() => _RequestVerificationModalState();
}


class _RequestVerificationModalState extends State<RequestVerificationModal> {
  String? selectedDocumentName;
  final ApiClient _client = ApiClient();
  final _commentsCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      request: widget.request,
      title: 'Request Verification',

      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(label: 'Request ID', value: widget.request.requestId ?? 'NULL'),
          DetailRow(label: 'Employee ID', value: widget.request.empId ?? 'NULL'),
          DetailRow(label: 'Employee Name', value: widget.request.employeeName ?? 'NULL'),
          DetailRow(label: 'Contact', value: widget.request.contact ?? 'NULL'),
          DetailRow(label: 'Email', value: widget.request.email?.toLowerCase() ?? 'NULL'),
          DetailRow(label: 'Grade', value: widget.request.grade ?? 'NULL'),
          DetailRow(label: 'Eligibility', value: widget.request.eligibility?.toString() ?? 'NULL'),
          DetailRow(label: 'Cost Center', value: widget.request.costCentre ?? 'NULL'),
          DetailRow(label: 'Vehicle Model', value: widget.request.carModel ?? 'NULL'),
          DetailRow(label: 'Manufactured by', value: widget.request.manufacturer ?? 'NULL'),
          DetailRow(label: 'Vehicle Type', value: widget.request.vehicleType ?? 'NULL'),
          DetailRow(label: 'Color', value: widget.request.colorChoice ?? 'NULL'),
          DetailRow(label: 'Quotation', value: widget.request.quotation?.toString() ?? 'NULL'),
          const SizedBox(height: 24),

          FormTextField(
            label: 'ES&A Comments',
            hint: 'Enter Your Comments',
            maxLines: 3,
            controller: _commentsCtrl,
            required: true,
          ),
          const SizedBox(height: 16),

          FileUploadField(
            label: 'Upload Document - File Type Allowed: .pdf/.txt/.docx',
            allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],
          ),
          const SizedBox(height: 16),

          DropdownField(
            label: 'View Document',
            hints: 'Select Document',
            items: ['Document 1', 'Document 2', 'Document 3'],
            onChanged: (value) {
              setState(() {
                selectedDocumentName = value;
              });
            },
            required: false,
          ),
          const SizedBox(height: 24),
        ],
      ),

      bottom: ActionButtonPair(
        primaryText: 'Approve',
        secondaryText: 'Reject',
        primaryMessage: '${widget.request.requestId}: Request Approved',
        secondaryMessage: '${widget.request.requestId}: Request Rejected',
        onPrimaryAction: _commentsCtrl == null
            ? () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter your comments',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFFFA6262),
              ),
            ),
            backgroundColor: Color(0xFFFFE3E3),
          ),
        )
            : () => _handleApprove(),
        onSecondaryAction: () => _handleReject(),
      ),
    );
  }

  Future<void> _handleApprove() async {
    final requestId = widget.request.requestId;
    final empId = widget.request.empId;

    if (requestId == null || empId == null ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing request or ES&A details')),
      );
      return;
    }

    try {
      final response = await _client.assignToInsurance(
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

    if (requestId == null ||
        requestId.isEmpty ||
        empId == null ||
        empId.isEmpty) {
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

      Navigator.pop(context, response);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    _commentsCtrl.dispose();
    super.dispose();
  }

}