import 'package:flutter/material.dart';

import '../widgets/action_button_pair.dart';
import '../widgets/request_card.dart';
import '../widgets/form_detail_row.dart';
import '../widgets/form_text_field.dart';
import '../widgets/file_uploader.dart';
import '../widgets/drop_down.dart';
import './base_modal.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_client.dart';

class InsuranceScreenModal extends StatefulWidget {
  final CarRequest request;

  const InsuranceScreenModal({
    super.key,
    required this.request,
  });

  @override
  State<InsuranceScreenModal> createState() =>
      _InsuranceScreenModalState();
}

class _InsuranceScreenModalState extends State<InsuranceScreenModal> {
  String? selectedDocumentName;
  final ApiClient _client = ApiClient();

  final _baseInsuranceCtrl = TextEditingController();
  final _addOnCoverCtrl = TextEditingController();
  final _addOnSapphireCtrl = TextEditingController();
  final _commentsCtrl = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return BaseModal(
      request: widget.request,
      title: widget.request.employeeName ?? '',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(widget.request),
          const SizedBox(height: 24),
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

          /// Base Insurance
          FormTextField(
            label: 'Base Insurance',
            hint: 'Enter Base Insurance',
            required: true,
            controller: _baseInsuranceCtrl,
          ),
          const SizedBox(height: 16),

          /// Addon Cover
          FormTextField(
            label: 'Addon Cover',
            hint: 'Enter Addon Cover',
            required: true,
            controller: _addOnCoverCtrl,
          ),
          const SizedBox(height: 16),

          /// Addon Sapphire Plus
          FormTextField(
            label: 'Addon Saphire Plus',
            hint: 'Enter Addon Saphire Plus',
            required: true,
            controller: _addOnSapphireCtrl,
          ),
          const SizedBox(height: 16),

          /// Upload Document
          const FileUploadField(
            label: 'Upload Document',
          ),
          const SizedBox(height: 16),

          /// Comments
          const FormTextField(
            label: 'Comments',
            hint: 'Enter Comments',
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          /// View Document
          DropdownField(
            label: 'View Document',
            hints: 'Select Document',
            items: const ['User Quotation Document'],
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
        onPrimaryAction: () => _handleApprove(),
        onSecondaryAction: () => _handleReject(),
      ),
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
  // Action button actual functions
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

  Future<void> _handleApprove() async {
    final requestId = widget.request.requestId;

    if (requestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing request')),
      );
      return;
    }

    try {
      final response = await _client.SubmitForInsuranceQuoteApproval(
        requestId: requestId,
        baseInsurance: int.tryParse(_baseInsuranceCtrl.text.trim()) ?? 0,
        addOnTataPower: int.tryParse(_addOnCoverCtrl.text.trim()) ?? 0,
        addOnSapphirePlus: int.tryParse(_addOnSapphireCtrl.text.trim()) ?? 0,
        commentsByGIT: (_commentsCtrl.text.trim().isEmpty)
            ? 'null'
            : _commentsCtrl.text.trim(),
      );

      Navigator.pop(context, response); // success close
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
