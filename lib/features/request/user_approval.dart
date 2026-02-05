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

enum ApprovalType {
  insuranceQuote,
  emiDeduction,
}

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

  // Single approval request and its type
  CarRequest? approvalRequest;
  ApprovalType? approvalType;

  Future<void> _loadUserApprovals() async {
    setState(() => isLoading = true);

    // Load from LocalPrefs
    final empId = await LocalPrefs.getEmpCode();
    final roleId = await LocalPrefs.getRoleId();

    if (empId == null || empId.isEmpty || roleId == null) {
      debugPrint('Invalid empId or roleId');
      setState(() => isLoading = false);
      return;
    }

    try {
      // API call
      final response = await _client.getApprovalStages(
        empId: empId,
        role: roleId,
      );

      // Check which approval type is present in the response
      final List<CarRequest> insuranceQuoteList =
          response.data['INSURANCE_QUOTE_APPROVAL_USER'] ?? [];

      final List<CarRequest> emiList =
          response.data['EMI_APPROVAL_USER'] ?? [];

      CarRequest? request;
      ApprovalType? type;

      // Determine which approval to display (priority: Insurance Quote first)
      if (insuranceQuoteList.isNotEmpty) {
        request = insuranceQuoteList.first;
        type = ApprovalType.insuranceQuote;
      } else if (emiList.isNotEmpty) {
        request = emiList.first;
        type = ApprovalType.emiDeduction;
      }

      // Update state
      setState(() {
        approvalRequest = request;
        approvalType = type;
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
    _loadUserApprovals();
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
            Navigator.pop(context);
            // Handle approval after declaration acceptance
          },
        );
      },
    );
  }

  void _handleInsuranceQuoteApproval() {
    // Handle insurance quote approval logic
    _showDeclarationModal();
  }

  void _handleInsuranceQuoteRejection() {
    // Handle insurance quote rejection logic
  }

  Widget _buildInsuranceQuoteApprovalContent(CarRequest request) {
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
        const SizedBox(height: 24),
        ActionButtonPair(
          primaryText: 'Approve',
          secondaryText: 'Reject',
          primaryMessage: 'Insurance Quote Approved',
          secondaryMessage: 'Insurance Quote Rejected',
          onPrimaryAction: _handleInsuranceQuoteApproval,
          onSecondaryAction: _handleInsuranceQuoteRejection,
        ),
      ],
    );
  }

  void _handleEmiDeductionApproval() {
    // Handle EMI deduction approval logic
  }

  void _handleEmiDeductionRejection() {
    // Handle EMI deduction rejection logic
  }

  Widget _buildEmiDeductionApprovalContent(CarRequest request) {
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
          hint: 'Your comments',
          maxLines: 3,
          required: true,
        ),
        const SizedBox(height: 24),
        ActionButtonPair(
          primaryText: 'Approve',
          secondaryText: 'Reject',
          primaryMessage: 'EMI Deduction Approved',
          secondaryMessage: 'EMI Deduction Rejected',
          onPrimaryAction: _handleEmiDeductionApproval,
          onSecondaryAction: _handleEmiDeductionRejection,
        ),
      ],
    );
  }

  Widget _buildApprovalContent() {
    if (approvalRequest == null || approvalType == null) {
      return const Center(
        child: Text(
          'No approval request available',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
          ),
        ),
      );
    }

    // Display content based on approval type
    switch (approvalType!) {
      case ApprovalType.insuranceQuote:
        return _buildInsuranceQuoteApprovalContent(approvalRequest!);
      case ApprovalType.emiDeduction:
        return _buildEmiDeductionApprovalContent(approvalRequest!);
    }
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
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildApprovalContent(),
          ],
        ),
      ),
    );
  }
}