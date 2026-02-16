import 'package:flutter/material.dart';
import '../../custom/modals/declaration_acceptance_modal.dart';
import '../../custom/widgets/file_uploader.dart';
import '../../custom/widgets/form_text_field.dart';
import '../../custom/widgets/form_detail_row.dart';
import '../../custom/widgets/drop_down.dart';
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
    super.key,
    this.approvalRequest,
  });

  @override
  State<UserApproval> createState() => _UserApprovalState();
}

class _UserApprovalState extends State<UserApproval> {
  final ApiClient _client = ApiClient();
  bool isLoading = true;
  final _commentsInsuranceCtrl = TextEditingController();
  final _commentsEmiCtrl = TextEditingController();
  String? addOnTataPowerValue;
  String? addOnSapphirePlusValue;
  // State variable to hold the approval request
  CarRequest? approvalRequest;
  // Single approval request and its type
  ApprovalType? approvalType;
  String? selectedInsuranceType;

  final _chassisNumberCtrl = TextEditingController();
  final _engineNumberCtrl = TextEditingController();
  final _fastTagNumberCtrl = TextEditingController();
  final _vehicleHandoverDateCtrl = TextEditingController();

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

    try
    {
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

      late CarRequest request;
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
    // Initialize from widget property if provided
    approvalRequest = widget.approvalRequest;
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

  // First Approval
  bool _validateBeforeInsuranceApprove() {
    final request = approvalRequest!;
    final comments = _commentsInsuranceCtrl.text.trim();

    if (selectedInsuranceType == null) {
      _showSnackBar(
        context: context,
        message: 'Please select Insurance Type',
        isSuccess: false,
      );
      return false;
    }

    addOnTataPowerValue =
    selectedInsuranceType == 'Add on Tata Power'
        ? (request.addOnCoverTataPower?.toString() ?? '')
        : '';

    addOnSapphirePlusValue =
    selectedInsuranceType == 'Add on Sapphire plus'
        ? (request.addOnSapphirePlus?.toString() ?? '')
        : '';

    if (comments.isEmpty) {
      _showSnackBar(
        context: context,
        message: 'Comments are required',
        isSuccess: false,
      );
      return false;
    }

    return true;
  }
  Future<void> _handleInsuranceQuoteApproval() async {
    final request = approvalRequest!;
    final requestId = request.requestId!;
    // Handle insurance quote approval logic
      try {
        final response = await _client.firstUserApproval(
          requestId: requestId,
          userApprovalComments: _commentsInsuranceCtrl.text.trim(),
          addOnTataPower: addOnTataPowerValue!,
          addOnSapphirePlus: addOnSapphirePlusValue!,
        );

        Navigator.pop(context, response); // success close
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
  }
  Future<void> _handleInsuranceQuoteRejection() async {
    // Handle insurance quote rejection logic
    final request = approvalRequest!;
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
  Widget _buildInsuranceQuoteApprovalContent(CarRequest request) {

    final String insuranceValue =
    selectedInsuranceType == 'Add on Tata Power'
        ? request.addOnCoverTataPower?.toString() ?? ''
        : selectedInsuranceType == 'Add on Sapphire plus'
        ? request.addOnSapphirePlus?.toString() ?? ''
        : '';

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
        DetailRow(label: 'Quoatation Amount', value: request.quotation?.toString() ?? 'NAN'),
        const SizedBox(height: 16),
        DetailRow(label: 'Base Insurance', value: request.baseInsurancePremium?.toString() ?? 'NAN'),
        const SizedBox(height: 16),
        DropdownField(
          label: 'Insurance add on',
          hints: 'Select Insurance Type',
          items: ['Add on Tata Power', 'Add on Sapphire plus'],
          onChanged: (value) {
            setState(() {
              selectedInsuranceType = value;
            });
          },
          required: true,
        ),
        const SizedBox(height: 16),
        if (selectedInsuranceType != null)
          DetailRow(
            label: selectedInsuranceType ?? '',
            value: insuranceValue,
          ),

        const SizedBox(height: 16),
        const FileUploadField(label: 'Upload Document'),
        const SizedBox(height: 16),
        FormTextField(
          label: 'Comments',
          hint: 'Your comments',
          maxLines: 3,
          required: true,
          controller: _commentsInsuranceCtrl,
        ),
        const SizedBox(height: 24),
        ActionButtonPair(
          primaryText: 'Approve',
          secondaryText: 'Reject',
          primaryValidator: _validateBeforeInsuranceApprove,
          onPrimaryAction: _handleInsuranceQuoteApproval,
          onSecondaryAction: _handleInsuranceQuoteRejection,
        ),
      ],
    );
  }

  // Second Approval
  bool _validateBeforeEmiApprove() {
    final comments = _commentsEmiCtrl.text.trim();

    // Check comments
    if (comments.isEmpty) {
      _showSnackBar(
        context: context,
        message: 'Enter Comments',
        isSuccess: false,
      );
      return false;

    }
    return true;
  }
  Future<void> _handleEmiDeductionApproval() async {
      final request = approvalRequest!;
      final requestId = request.requestId;
      final empId = request.empId;

      if (requestId == null || empId == null ) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing request or ES&A details')),
        );
        return;
      }

      try {
        final response = await _client.secondUserApproval(
          requestId: requestId,
          empId: empId,
          commentsAssignedToEsna: _commentsEmiCtrl.text.trim(),
        );

        Navigator.pop(context, response); // success close
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  Future<void> _handleEmiDeductionRejection() async {
    // Handle EMI deduction rejection logic
    final request = approvalRequest!;
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

      // Navigator.pop(context, response); // success close
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
  Widget _buildEmiDeductionApprovalContent(CarRequest request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EMI Deduction Approval (Stage 25)',
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
          controller: _commentsEmiCtrl,
        ),
        const SizedBox(height: 24),
        ActionButtonPair(
          primaryText: 'Approve',
          secondaryText: 'Reject',
          primaryValidator: _validateBeforeEmiApprove,
          onPrimaryAction: _handleEmiDeductionApproval,
          onSecondaryAction: _handleEmiDeductionRejection,
        ),
      ],
    );
  }

  // Entry point: No user approval screen validation
  Widget _buildApprovalContent() {
    if (approvalRequest == null || approvalType == null) {
      return const Center(
        child: SizedBox(
          width: double.infinity,
          height: 600,
          child: Center(
            child: Text('You have No approval request available'),
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
          ? const Center(child: CircularProgressIndicator(color: Color.fromRGBO(
          98, 202, 102, 1.0),))
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