import 'package:flutter/material.dart';
import '../../network/api_models/car_request.dart';
// Customs
import '../widgets/form_detail_row.dart';
import '../widgets/action_button_pair.dart';
import './base_modal.dart';

class DeleteRequestModal extends StatefulWidget {
  final CarRequest request;

  const DeleteRequestModal({
    super.key,
    required this.request,
  });

  @override
  State<DeleteRequestModal> createState() =>
      _DeleteRequestModalState();
}

class _DeleteRequestModalState extends State<DeleteRequestModal> {
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Delete Request',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this request?',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF808080),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final requestId = widget.request.requestId;
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close modal

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$requestId has been deleted',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFFFF3C3C),
                    ),
                  ),
                  backgroundColor: const Color(0xFFFFE3E3),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return BaseModal(
      request: request,
      title: request.requestId ?? '',

      /// CONTENT
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(label: 'Employee ID', value: request.empId ?? 'NULL'),
          DetailRow(label: 'Employee Name', value: request.employeeName ?? 'NULL'),
          DetailRow(label: 'Contact', value: request.contact ?? 'NULL'),
          DetailRow(label: 'Email', value: request.email ?? 'NULL'),
          DetailRow(label: 'Vehicle Name', value: request.carModel ?? 'NULL'),
          DetailRow(label: 'Manufactured by', value: request.manufacturer ?? 'NULL'),
          DetailRow(label: 'Vehicle Type', value: request.vehicleType ?? 'NULL'),
          DetailRow(label: 'Vehicle Model', value: request.carModel ?? 'NULL'),
          DetailRow(label: 'Color', value: request.colorChoice ?? 'NULL'),
          DetailRow(label: 'Grade', value: request.grade ?? 'NULL'),
          DetailRow(
            label: 'Eligibility',
            value: request.eligibility?.toString() ?? 'NULL',
          ),
          DetailRow(
            label: 'Total',
            value: request.totalEmi?.toString() ?? 'NULL',
          ),
          const SizedBox(height: 16),
          _buildStatusRow(request),
          const SizedBox(height: 8),
        ],
      ),

      /// BOTTOM (DELETE MOVED HERE ✅)
      bottom: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showDeleteConfirmation(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(255, 227, 227, 1.0),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Delete Request',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(250, 98, 98, 1.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(CarRequest request) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'STATUS',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          request.stage?.label ?? 'NULL',
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
