import 'package:flutter/material.dart';
import '../../network/api_models/car_request.dart';
// Customs
import '../widgets/form_detail_row.dart';
import '../widgets/form_text_field.dart';
import '../widgets/file_uploader.dart';
import '../widgets/drop_down.dart';
import '../widgets/action_button_pair.dart';
import './base_modal.dart';

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

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      request: widget.request,
      title: 'Request Verification',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ES&A Info fields
          DetailRow(label: 'Employee Name', value: widget.request.employeeName ?? 'NULL'),
          DetailRow(label: 'Employee ID', value: widget.request.empId ?? 'NULL'),
          DetailRow(label: 'Grade',value: widget.request.grade ?? 'NULL'),
          DetailRow(label: 'Manufactured by', value: widget.request.manufacturer ?? 'NULL'),
          DetailRow(label: 'Vehicle Type', value: widget.request.vehicleType ?? 'NULL'),
          DetailRow(label: 'Vehicle Model', value: widget.request.carModel ?? 'NULL'),
          DetailRow(label: 'Email', value: widget.request.email ?? 'NULL'),
          DetailRow(label: 'Color', value: widget.request.colorChoice ?? 'NULL'),
          const SizedBox(height: 24),

          // ES&A Input fields
          const FormTextField(label: 'ES&A Comments', hint: 'Enter Your Comments', maxLines: 3, required: true,),
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

}