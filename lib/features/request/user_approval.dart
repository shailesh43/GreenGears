import 'package:flutter/material.dart';
import '../../custom/modals/declaration_acceptance_modal.dart';
import '../../custom/widgets/file_uploader.dart';
import '../../custom/widgets/form_text_field.dart';
import '../../custom/widgets/form_detail_row.dart';
import '../../custom/widgets/action_button_pair.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_client.dart';
import '../../network/api_models/user_approval_model.dart';
import '../../constants/local_prefs.dart';

class UserApproval extends StatefulWidget {
  final CarRequest? approvalRequest;

  const UserApproval({
    this.approvalRequest,
    super.key,
  });

  @override
  State<UserApproval> createState() => _UserApprovalState();
}

class _UserApprovalState extends State<UserApproval> {
  final ApiClient _client = ApiClient();
  bool isLoading = true;
  CarRequest? approvalRequest;

  Future<void> _loadEmiApprovalRequest() async {
    setState(() => isLoading = true);

    // 1️⃣ Load from LocalPrefs
    final empId = await LocalPrefs.getEmpCode();
    final roleId = await LocalPrefs.getRoleId();

    if (empId == null || empId.isEmpty || roleId == null) {
      debugPrint('Invalid empId or roleId');
      setState(() => isLoading = false);
      return;
    }

    try {
      // 2️⃣ API call
      final response = await _client.getApprovalStages(
        empId: empId,
        role: roleId,
      );

      // 3️⃣ Safely pick FIRST request of EMI_APPROVAL_USER
      final List<CarRequest> emiList =
          response.data['EMI_APPROVAL_USER'] ?? [];

      final CarRequest? emiRequest =
      emiList.isNotEmpty ? emiList.first : null;

      // 4️⃣ Update state
      setState(() {
        approvalRequest = emiRequest;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching approval stages: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize with widget's approvalRequest if provided
    approvalRequest = widget.approvalRequest;
    _loadEmiApprovalRequest();
  }

  void _showDeclarationModal() {
    if (approvalRequest == null) {
      debugPrint('No approval request available');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DeclarationAcceptanceModal(
          request: approvalRequest!,
          onAccept: () {
            Navigator.pop(context); // Close modal
            // _handleApproval(approvalRequest!);
          },
        );
      },
    );
  }

  Widget _buildFirstApprovalContent(CarRequest request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insurance Quote Approval',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 24),
        DetailRow(label: 'EMP ID', value: request.empId ?? ''),
        DetailRow(label: 'EMP Name', value: request.employeeName ?? ''),
        DetailRow(label: 'Mobile No', value: request.contact ?? ''),
        DetailRow(label: 'Request ID', value: request.requestId ?? ''),
        DetailRow(label: 'Grade', value: request.grade ?? ''),
        DetailRow(label: 'Email', value: request.email ?? ''),
        DetailRow(label: 'Total EMI (₹)', value: request.totalEmi?.toString() ?? ''),
        DetailRow(label: 'Car Allowance', value: request.carAllowance?.toString() ?? ''),
        DetailRow(label: 'Company Contribution', value: request.companyContribution?.toString() ?? ''),
        const SizedBox(height: 16),
        const FileUploadField(label: 'Upload Document'),
        const SizedBox(height: 16),
        FormTextField(
          label: 'Comments',
          hint: 'Your comments',
          maxLines: 3,
          required: true,
        ),
      ],
    );
  }

  Widget _buildSecondApprovalContent(CarRequest request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Deduction',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 24),
        DetailRow(label: 'EMP ID', value: request.empId ?? ''),
        DetailRow(label: 'EMP Name', value: request.employeeName ?? ''),
        DetailRow(label: 'Mobile No', value: request.contact ?? ''),
        DetailRow(label: 'Request ID', value: request.requestId ?? ''),
        DetailRow(label: 'Grade', value: request.grade ?? ''),
        DetailRow(label: 'Eligibility (₹)', value: request.eligibility?.toString() ?? ''),
        DetailRow(label: 'Email', value: request.email ?? ''),
        const SizedBox(height: 16),
        DetailRow(
          label: 'Total EMI (₹)',
          value: request.totalEmi?.toString() ?? '',
        ),
        DetailRow(
          label: 'Car Allowance',
          value: request.carAllowance?.toString() ?? '',
        ),
        DetailRow(
          label: 'Company Contribution (₹)',
          value: request.companyContribution?.toString() ?? '',
        ),
        DetailRow(
          label: 'EMI Tenure (YRS)',
          value: request.completeEmiTenure?.toString() ?? '',
        ),
        const SizedBox(height: 16),
        const FileUploadField(label: 'Upload Document'),
        const SizedBox(height: 16),
        FormTextField(
          label: 'Employee Comments',
          maxLines: 3,
          required: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Approve/Reject',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : approvalRequest == null
          ? const Center(
        child: Text(
          'No approval request available',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
          ),
        ),
      )
          : Column(
        children: [
          // 📼 Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  approvalRequest!.stage == 25
                      ? _buildFirstApprovalContent(approvalRequest!)
                      : _buildSecondApprovalContent(approvalRequest!),
                ],
              ),
            ),
          ),
          // 📽 Fixed bottom buttons
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: ActionButtonPair(
                  primaryText: 'Approve',
                  secondaryText: 'Reject',
                  primaryMessage: 'Request Approved',
                  secondaryMessage: 'Request Rejected',
                  onPrimaryAction: () {
                    // handle approval

                  },
                  onSecondaryAction: () {
                    // handle rejection
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}