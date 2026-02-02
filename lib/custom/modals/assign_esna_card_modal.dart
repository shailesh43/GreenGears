import 'package:flutter/material.dart';

import '../widgets/action_button_pair.dart';
import '../widgets/request_card.dart';
import '../widgets/form_detail_row.dart';
import '../widgets/drop_down.dart';
import './base_modal.dart';
import '../../network/api_models/car_request.dart';

class AssignEsnaCardModal extends StatefulWidget {
  final CarRequest request;
  final List<String> esnaList;

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
  String? selectedEsnaName;

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
            items: widget.esnaList,
            onChanged: (value) {
              setState(() {
                selectedEsnaName = value;
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
            : '$selectedEsnaName has been assigned to ${request.requestId} Request ID.',
        secondaryMessage: 'Request Rejected',
        onPrimaryAction: selectedEsnaName == null
            ? null
            : () {
          // TODO: approve logic
        },
        onSecondaryAction: () {
          // TODO: reject logic
        },
      ),
    );
  }
}
