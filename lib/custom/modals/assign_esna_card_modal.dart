import 'package:flutter/material.dart';
import '../widgets/action_button_pair.dart';
import '../widgets/request_card.dart';
import '../widgets/form_detail_row.dart';
import '../widgets/drop_down.dart';
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
  State<AssignEsnaCardModal> createState() => _AssignEsnaCardModalState();
}

class _AssignEsnaCardModalState extends State<AssignEsnaCardModal> {
  String? selectedDocumentName;
  String? selectedEsnaName;

  @override
  Widget build(BuildContext context) {
    final request = widget.request;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        request.employeeName ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(request),
                      const SizedBox(height: 24),

                      DetailRow(label: 'Vehicle Model', value: request.carModel ?? '—'),
                      DetailRow(label: 'Manufactured by', value: request.manufacturer ?? '—'),
                      DetailRow(label: 'Color', value: request.colorChoice ?? '—'),
                      DetailRow(label: 'Employee Name', value: request.employeeName ?? '—'),
                      DetailRow(label: 'Employee ID', value: request.empId ?? '—'),
                      DetailRow(label: 'Phone', value: request.contact ?? '—'),
                      DetailRow(label: 'Company', value: request.company ?? '—'),
                      DetailRow(label: 'Grade', value: request.grade ?? '—'),
                      DetailRow(label: 'Email', value: request.email ?? '—'),
                      DetailRow(
                        label: 'Eligibility',
                        value: request.eligibility?.toString() ?? '—',
                      ),
                      DetailRow(
                        label: 'Quotation Amount',
                        value: request.quotation?.toString() ?? '—',
                      ),

                      const SizedBox(height: 24),

                      // ES&A Dropdown
                      DropdownField(
                        label: 'Assign ES&A to the Request',
                        hints: 'Select ES&A',
                        items: widget.esnaList,
                        onChanged: (value) {
                          setState(() {
                            selectedEsnaName = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Document Dropdown
                      DropdownField(
                        label: 'View Document',
                        hints: 'Select Document',
                        items: const ['User Quotation Document'],
                        onChanged: (value) {
                          setState(() {
                            selectedDocumentName = value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      ActionButtonPair(
                        primaryText: 'Approve',
                        secondaryText: 'Reject',
                        primaryMessage:
                        selectedEsnaName == null
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          request.requestId ?? '',
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
}
