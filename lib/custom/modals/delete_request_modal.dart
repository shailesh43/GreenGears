import 'package:flutter/material.dart';
import '../widgets/form_detail_row.dart';

class DeleteRequestModal extends StatelessWidget {
  final Map<String, dynamic> request;

  DeleteRequestModal({
    super.key,
    required this.request
  });

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Request',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this request?',
            style: TextStyle(
              fontFamily: 'Inter',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color.fromRGBO(128, 128, 128, 1.0),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final requestId = request['requestId'] ?? 'CAR2025242';
                Navigator.of(context).pop();// Close dialog

                // Show snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$requestId has been deleted',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(255, 60, 60, 1.0),
                      ),
                    ),
                    backgroundColor: Color.fromRGBO(255, 227, 227, 1.0),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(context),
                    ),
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
                      DetailRow(label: 'Vehicle Name', value:  'RE Guerilla'),
                      DetailRow(label: 'Employee Name', value:  'Rahil Bopche'),
                      DetailRow(label: 'Employee ID', value:  '209164'),
                      DetailRow(label: 'Phone', value:  '+84549721'),
                      DetailRow(label: 'Date of Request', value:  '01/11/2019'),
                      DetailRow(label: 'Company', value:  'The Tata Power Co. Ltd.'),
                      DetailRow(label:
                        'Address', value:
                        'Technopolis Knowledge Park\n4th floor, Andheri (E),\nMumbai 400093',
                        isMultiline: true,
                      ),
                      const SizedBox(height: 8),
                      DetailRow(label:
                        'Cluster', value:
                         'The Tata Power Co. Ltd.\nCorporate functions\n& International',
                        isMultiline: true,
                      ),
                      DetailRow(label: 'Grade', value:  'ME03'),
                      DetailRow(label: 'Cost center', value:  '1900022041'),
                      DetailRow(label: 'Eligibility', value: '₹ 4300.50'),
                      const SizedBox(height: 12),
                      DetailRow(label: 'Total', value: '₹ 10,00, 000',),
                      const SizedBox(height: 12),
                      _buildStatusRow(request),
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
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(Map<String, dynamic> request) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'STATUS',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Text(
          request['requestStatus'] ?? 'Requested to ES&A',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2196F3),
          ),
        ),
      ],
    );
  }
}