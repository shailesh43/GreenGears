import 'package:flutter/material.dart';
import 'package:greengears/network/api_models/car_request.dart';
import '../../custom/widgets/form_detail_row.dart';
import '../../constants/local_prefs.dart';
import '../../network/api_client.dart';
import 'package:intl/intl.dart';

class ActiveRequestPage extends StatefulWidget {
  final CarRequest request;

  const ActiveRequestPage({
    super.key,
    required this.request,
  });

  @override
  State<ActiveRequestPage> createState() => _ActiveRequestPageState();
}

class _ActiveRequestPageState extends State<ActiveRequestPage> {
  String? empCode;
  int? roleId;

  final ApiClient _client = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadEmpCodeAndRole();
  }

  Future<void> _loadEmpCodeAndRole() async {
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
              final request = widget.request;

              // Safety check: prefs must be loaded
              if (roleId == null || empCode == null) {
                _showSnackBar(
                  context: context,
                  message: 'Please wait, loading user details...',
                  isSuccess: false,
                );
                return;
              }

              Navigator.pop(context); // close confirmation dialog

              await _handleDeleteRequest(
                context,
                request: request,
                roleId: roleId!,
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
        required CarRequest request,
        required int roleId,
      }) async
  {
    try {
      if (!mounted) return;

      final response = await _client.deleteRequest(
        requestId: request.requestId!,
        role: roleId,
        empId: request.empId!,
      );

      _showSnackBar(
        context: context,
        message: 'Request deleted successfully',
        isSuccess: true,
      );

      // Refresh dashboard / pop page if needed
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          request.requestId ?? '',
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(label: 'Request ID', value: widget.request.requestId ?? 'NULL'),
                  DetailRow(label: 'Employee ID', value: widget.request.empId ?? 'NULL'),
                  DetailRow(label: 'Employee Name', value: widget.request.employeeName ?? 'NULL'),
                  DetailRow(label: 'Contact', value: widget.request.contact ?? 'NULL'),
                  DetailRow(label: 'Email', value: widget.request.email?.toLowerCase() ?? 'NULL'),
                  DetailRow(
                    label: 'Date Of Request',
                    value: widget.request.updatedTime != null
                        ? DateFormat('dd/MM/yyyy').format(widget.request.updatedTime!)
                        : 'NULL',
                  ),
                  DetailRow(label: 'Grade', value: widget.request.grade ?? 'NULL'),
                  DetailRow(label: 'Eligibility', value: widget.request.eligibility?.toString() ?? 'NULL'),
                  DetailRow(label: 'Cost Center', value: widget.request.costCentre ?? 'NULL'),
                  DetailRow(label: 'Vehicle Model', value: widget.request.carModel ?? 'NULL'),
                  DetailRow(label: 'Manufactured by', value: widget.request.manufacturer ?? 'NULL'),
                  DetailRow(label: 'Vehicle Type', value: widget.request.vehicleType ?? 'NULL'),
                  DetailRow(label: 'Color', value: widget.request.colorChoice ?? 'NULL'),
                  DetailRow(label: 'Quotation', value: widget.request.quotation?.toString() ?? 'NULL'),
                  const SizedBox(height: 16),
                  _buildStatusRow(request),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showDeleteConfirmation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(255, 227, 227, 1.0),
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
        ],
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
}