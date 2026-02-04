import 'package:flutter/material.dart';
import '../../network/api_models/car_request.dart';
// Customs
import '../widgets/form_detail_row.dart';
import '../widgets/action_button_pair.dart';
import './base_modal.dart';

import '../../constants/local_prefs.dart';
import '../../network/api_client.dart';

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

  String? empCode;
  int? roleId;
  String? requestId;

  final ApiClient _client = ApiClient();

  Future<void> _loadEmpCodeAndRol() async {
    empCode = await LocalPrefs.getEmpCode();
    roleId = await LocalPrefs.getRoleId();
  }

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
            onPressed: () {
              Navigator.pop(context); // close dialog
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF808080),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final requestId = widget.request!.requestId;

              Navigator.pop(context); // close confirmation dialog
              Navigator.pop(context); // close request details modal (if any)

              await _handleDeleteRequest(
                context,
                requestId: requestId!,
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

  Future<void> _handleDeleteRequest(
      BuildContext context, {
        required String requestId,
      }) async {
    try {

      if (roleId == null || empCode == null || widget.request == null) {
        _showSnackBar(
          context: context,
          message: 'Unable to delete request. Please try again.',
          isSuccess: false,
        );
        return;
      }
      final response = await _client.deleteRequest(
        requestId: requestId,
        role: roleId!, // your logged-in role
        empId: empCode!, // logged-in employee id
      );

      if (!mounted) return;

      _showSnackBar(
        context: context,
        message: response.message ?? 'Request deleted successfully',
        isSuccess: true,
      );

      // 🔁 Refresh dashboard / pop page if needed
      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;

      _showSnackBar(
        context: context,
        message: e.toString(),
        isSuccess: false,
      );
    }
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

  void _showSnackBar({
    required BuildContext context,
    required String message,
    required bool isSuccess,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Inter',
            color: isSuccess
                ? const Color(0xFF388E3B)
                : const Color(0xFFFA6262),
          ),
        ),
        backgroundColor: isSuccess
            ? const Color(0xFFD7FFD8)
            : const Color(0xFFFFE3E3),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
