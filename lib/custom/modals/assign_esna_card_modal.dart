import 'package:flutter/material.dart';

import '../widgets/action_button_pair.dart';
import '../widgets/request_card.dart';
import '../widgets/form_detail_row.dart';
import '../widgets/drop_down.dart';
import './base_modal.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_models/list_of_esna_model.dart';
import '../../network/api_client.dart';

class AssignEsnaCardModal extends StatefulWidget {
  final CarRequest request;
  final List<GetListOfEsnaModel> esnaList;

  const AssignEsnaCardModal({
    super.key,
    required this.request,
    required this.esnaList,
  });

  @override
  State<AssignEsnaCardModal> createState() =>
      _AssignEsnaCardModalState();
}

class _AssignEsnaCardModalState extends State<AssignEsnaCardModal> {
  String? selectedDocumentName;
  // List<GetListOfEsnaModel> esnaList = [];
  String? selectedEsnaName;
  String? selectedEsnaEmpId;
  final ApiClient _client = ApiClient();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final request = widget.request;

    return BaseModal(
      request: request,
      title: request.requestId ?? '',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(
            label: 'Employee Name',
            value: request.employeeName ?? '—',
          ),
          DetailRow(
            label: 'Employee ID',
            value: request.empId ?? '—',
          ),
          DetailRow(
            label: 'Phone',
            value: request.contact ?? '—',
          ),
          DetailRow(
            label: 'Company',
            value: request.company ?? '—',
          ),
          DetailRow(
            label: 'Email',
            value: request.email?.toLowerCase() ?? '—',
          ),
          DetailRow(
            label: 'Vehicle Model',
            value: request.carModel ?? '—',
          ),
          DetailRow(
            label: 'Manufactured by',
            value: request.manufacturer ?? '—',
          ),
          DetailRow(
            label: 'Vehicle Type',
            value: request.vehicleType ?? '—',
          ),
          DetailRow(
            label: 'Color',
            value: request.colorChoice ?? '—',
          ),
          DetailRow(
            label: 'Grade',
            value: request.grade ?? '—',
          ),
          DetailRow(
            label: 'Eligibility',
            value: request.eligibility?.toString() ?? '—',
          ),
          DetailRow(
            label: 'Quotation Amount',
            value: request.quotation?.toString() ?? '—',
          ),

          const SizedBox(height: 24),
          /// ES&A Dropdown
          DropdownField(
            label: 'Assign ES&A to the Request',
            hints: 'Select ES&A',
            items: widget.esnaList
                .map((e) => e.shortName.trim())
                .toList(),
            onChanged: (value) {
              if (value == null) return;

              final esnaSelected = widget.esnaList.firstWhere(
                    (e) => e.shortName.trim() == value.trim(),
                orElse: () => throw Exception('ES&A not found'),
              );

              setState(() {
                selectedEsnaName = esnaSelected.shortName;
                selectedEsnaEmpId = esnaSelected.empId;
              });
            },
            required: true,
          ),



          const SizedBox(height: 16),

          /// View Document Dropdown
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
        primaryMessage: selectedEsnaName == null
            ? 'Please select ES&A'
            : '$selectedEsnaName has been assigned to ${widget.request.requestId} Request ID.',
        secondaryMessage: 'Request Rejected',
        onPrimaryAction: selectedEsnaName == null
            ? () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select ES&A',
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
    final esnaEmpId = selectedEsnaEmpId;

    if (requestId == null || esnaEmpId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing request or ES&A details')),
      );
      return;
    }

    try {
      final response = await _client.assignOrUpdateEsnaSpoc(
        requestId: requestId,
        assignedEsnaEmpId: esnaEmpId,
      );

      Navigator.pop(context, response); // success close
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
