import 'package:flutter/material.dart';
import '../../network/api_models/car_request.dart';

// Customs
import '../widgets/action_button_pair.dart';
import '../widgets/form_detail_row.dart';
import '../widgets/form_text_field.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/file_uploader.dart';
import '../widgets/drop_down.dart';
import './base_modal.dart';

class RtoTaxReceiptModal extends StatefulWidget {
  final CarRequest request;

  RtoTaxReceiptModal({
    super.key,
    required this.request
  });

  @override
  State<RtoTaxReceiptModal> createState() => _RtoTaxReceiptModalState();

}

class _RtoTaxReceiptModalState extends State<RtoTaxReceiptModal> {
  String? selectedDocumentName;

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      request: widget.request,
      title: 'RTO Tax Receipt',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(label: 'Request ID', value: widget.request.requestId ?? 'NULL'),
          const SizedBox(height: 8),
          DetailRow(label: 'EMP ID',value: widget.request.empId ?? 'NULL'),
          const SizedBox(height: 8),
          DetailRow(label: 'EMP name', value: widget.request.employeeName ?? 'NULL'),
          const SizedBox(height: 8),
          DetailRow(label: 'Vehicle model',value: widget.request.carModel ?? 'NULL'),
          const SizedBox(height: 16),
          const FormTextField(label: 'Vehicle Number', hint: 'Enter Vehicle number', required: true,),
          const SizedBox(height: 16),
          const FormTextField(label: 'Chassis Number', hint: 'Enter Chassis number', required: true,),
          const SizedBox(height: 16),
          const FormTextField(label: 'Engine Number', hint: 'Enter Engine number', required: true,),
          const SizedBox(height: 16),
          const FormTextField(label: 'Fastag Number', hint: 'Enter Fastag Number', required: true,),
          const SizedBox(height: 16),
          const DatePickerField(label: 'Vehicle Handover Date'),
          const SizedBox(height: 16),
          const FileUploadField(label: 'Upload Files'),
          const SizedBox(height: 16),
          DropdownField(
            label: 'View Document',
            hints: 'Select Document',
            items: ['RTO Certificate', 'Tax Receipt', 'Insurance Copy'],
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
        primaryMessage: 'Request Approved',
        secondaryMessage: 'Request Rejected',
        onPrimaryAction: () {
          // Handle approve logic
        },
        onSecondaryAction: () {
          // Handle reject logic
        },
      ),
    );
  }
}