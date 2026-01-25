import 'package:flutter/material.dart';
import '../widgets/action_button_pair.dart';
import '../widgets/request_card.dart';
import '../widgets/form_detail_row.dart';
import '../widgets/drop_down.dart';


class AssignEsnaCardModal extends StatelessWidget {
  final Map<String, dynamic> request;

  const AssignEsnaCardModal({
    super.key,
    required this.request
  });

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
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
                        request['employeeName'] ?? 'Rahil Bopche',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40)
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
                      DetailRow(label:
                          'Vehicle Model', value: 'XUV700'),
                      DetailRow(label: 'Manufactured by',
                          value:  'Mahindra'),
                      DetailRow(label:
                          'Color', value: 'Black'),
                      DetailRow(label: 'Employee Name',
                         value:   'Rahil Bopche'),
                      DetailRow(
                          label: 'Employee ID',value:   '209164'),
                      DetailRow(label: 'Phone', value: '84549721'),
                      DetailRow(label: 'Company',
                           value: 'The Tata Power Co. Ltd.'),
                      DetailRow(label: 'Grade',value: 'ME03'),
                      DetailRow(
                          label: 'Email', value:  '1900022041'),
                      DetailRow(
                          label: 'Eligibility',value:   '₹ 50,000'),
                      DetailRow(
                         label:  'Quotation Amount',  value: '₹ 5,00,000'),
                      const SizedBox(height: 24),

                      // Select ES&A Dropdown
                      const SizedBox(height: 8),
                      DropdownField(
                        label: 'Assign ES&A to the Request',
                        hints: 'Select ES&A',
                        items: ['Mr. Aditya Bakshi', 'Mrs. Naina Mukharjee', 'Mr. Samay Gupta'],
                      ),
                      const SizedBox(height: 16),

                      // View Document Dropdown
                      DropdownField(
                        label: 'View Document',
                        hints: 'Select Document',
                        items: ['User Quotation Document'],
                      ),
                      const SizedBox(height: 24),

                      // Proceed Button
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(Map<String, dynamic> request) {
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
          request['requestId'] ?? 'CAR2025242',
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