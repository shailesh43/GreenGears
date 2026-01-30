import 'package:flutter/material.dart';
import '../../custom/modals/declaration_acceptance_modal.dart';
import '../../custom/widgets/file_uploader.dart';
import '../../custom/widgets/form_text_field.dart';
import '../../custom/widgets/form_detail_row.dart';
import '../../custom/widgets/action_button_pair.dart';
import '../../network/api_models/car_request.dart';

class UserApproval extends StatefulWidget {
  final int stage; // 23 for first approval, 25 for second approval
  final CarRequest request;

  const UserApproval({
    super.key,
    required this.stage,
    required this.request,
  });

  @override
  State<UserApproval> createState() => _UserApprovalState();
}

class _UserApprovalState extends State<UserApproval> {


  void _showDeclarationModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DeclarationAcceptanceModal(
          request: widget.request,
          onAccept: () {
            Navigator.pop(context); // Close modal
            _handleApproval();
          },
        );
      },
    );
  }

  void _handleApproval() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Request Approved',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF388E3B),
          ),
        ),
        backgroundColor: Color(0xFFD7FFD8),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  void _handleRejection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Request Rejected',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFFD32F2F),
          ),
        ),
        backgroundColor: Color(0xFFFFCDD2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  Widget _buildFirstApprovalContent() {
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
        const SizedBox(height: 24,),
        DetailRow(label: 'EMP ID', value:  '209164'),
        DetailRow(label: 'EMP Name', value:  'Rahil Bopche'),
        DetailRow(label: 'Mobile No', value:  '8453627897'),
        DetailRow(label: 'Request ID', value:  'CAR2025241'),
        DetailRow(label: 'EMP name', value:  'Rahil Bopche'),
        DetailRow(label: 'Grade', value:  'ME03'),
        DetailRow(label: 'Eligibility (RS)', value:  '50,000'),
        DetailRow(label: 'Email', value:  'rahil.bopche@tatapower.com'),
        DetailRow(label: 'ESNA comments', value:  'Approved'),
        const SizedBox(height: 16),
        DetailRow(label: 'Total EMI (in RS)', value:  '36,460'),
        DetailRow(label: 'Car Allowance', value:  '13,500'),
        DetailRow(label: 'Company Contribution', value:  '3800'),
        DetailRow(label: 'EMI tenure (YRS)', value:  '3 years'),
        const SizedBox(height: 16),
        const FileUploadField(label: 'Upload Document'),
        const SizedBox(height: 16),
        FormTextField(
          label: 'Comments',
          hint: 'Your comments',
          maxLines: 3,
          required: true,
          // controller: _commentsController,
        ),
      ],
    );
  }

  Widget _buildSecondApprovalContent() {
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
        DetailRow(label: 'EMP ID', value:  '208829'),
        DetailRow(label: 'EMP Name', value:  'Rahil Bopche'),
        DetailRow(label: 'Mobile No', value:  '8453627897'),
        DetailRow(label: 'Request ID', value:  'CAR2025241'),
        DetailRow(label: 'EMP name', value:  'Rahil Bopche'),
        DetailRow(label: 'Grade', value:  'ME03'),
        DetailRow(label: 'Eligibility (RS)', value:  '50,000'),
        DetailRow(label: 'Email', value:  'rahil.bopche@tatapower.com'),
        DetailRow(label: 'ESNA comments', value:  'Approved'),
        const SizedBox(height: 16),
        DetailRow(label: 'Total EMI (in RS)', value:  '36,460'),
        DetailRow(label: 'Car Allowance', value:  '13,500'),
        DetailRow(label: 'Company Contribution (RS)', value:  '3800'),
        DetailRow(label: 'EMI tenure (YRS)', value:  '3 years'),
        const SizedBox(height: 16),
        const FileUploadField(label: 'Upload Document'),
        const SizedBox(height: 16),
        FormTextField(
          label: 'Employee Comments',
          maxLines: 3,
          required: true,
          // controller: _commentsController,
        ),
      ],
    );
  }

  @override
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

      // 🔼 Scrollable content
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // 👈 space for buttons
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            widget.stage == 23
                ? _buildFirstApprovalContent()
                : _buildSecondApprovalContent(),
          ],
        ),
      ),

      // 🔽 Fixed bottom buttons
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ActionButtonPair(
            primaryText: 'Approve',
            secondaryText: 'Reject',
            primaryMessage: 'Request Approved',
            secondaryMessage: 'Request Rejected',
            onPrimaryAction: () {
              if (widget.stage == 25) {
                _showDeclarationModal();
              } else {
                _handleApproval();
              }
            },
            onSecondaryAction: () {
              // handle reject
            },
          ),
        ),
      ),
    );
  }

}


