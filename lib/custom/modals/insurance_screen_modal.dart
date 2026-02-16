import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:file/file.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../widgets/action_button_pair.dart';
import '../widgets/request_card.dart';
import '../widgets/form_detail_row.dart';
import '../widgets/form_text_field.dart';
import '../widgets/file_uploader.dart';
import '../widgets/drop_down.dart';
import './base_modal.dart';
import '../../network/api_models/car_request.dart';

import '../../core/utils/enum.dart';
import '../../network/api_client.dart';
import '../../custom/widgets/file_uploader.dart';

class InsuranceScreenModal extends StatefulWidget {
  final CarRequest request;

  const InsuranceScreenModal({
    super.key,
    required this.request,
  });

  @override
  State<InsuranceScreenModal> createState() =>
      _InsuranceScreenModalState();
}

class _InsuranceScreenModalState extends State<InsuranceScreenModal> {
  String? selectedDocumentName;
  final ApiClient _client = ApiClient();
  String? commentsOnInsurance;

  final _baseInsuranceCtrl = TextEditingController();
  final _addOnCoverCtrl = TextEditingController();
  final _addOnSapphireCtrl = TextEditingController();
  final _commentsCtrl = TextEditingController();

  // TODO: For Document upload & Progress
  PlatformFile? uploadedQuotationFile;
  double _uploadProgress = 0.0;   // 0.0 → 1.0 for LinearProgressIndicator
  bool _isUploading = false;

  Map<String, dynamic> _bindUploadDocRequestBody() {
    if (uploadedQuotationFile == null) {
      throw Exception('No file selected');
    }

    return {
      'emp_id': widget.request.empId.toString(),
      'process_stage': (Stage.requested?.stageNo ?? 20).toString(),
      'doc_id': (Document.initialQuotationDoc?.docId ?? 1).toString(),

      // MUST be a LIST for multer.array("files")
      'files': [
        MultipartFile.fromBytes(
          uploadedQuotationFile!.bytes!, // 🔴 buffer
          filename: uploadedQuotationFile!.name, // 🔴 originalname
        ),
      ],
    };
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCommentsByRequestId();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      request: widget.request,
      title: widget.request.employeeName ?? '',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(widget.request),
          const SizedBox(height: 24),
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
          DetailRow(label: 'Comments by ES&A', value: commentsOnInsurance?.toString() ?? 'NULL'),
          const SizedBox(height: 24),

          /// Base Insurance
          FormTextField(
            label: 'Base Insurance',
            hint: 'Enter Base Insurance',
            required: true,
            controller: _baseInsuranceCtrl,
          ),
          const SizedBox(height: 16),

          /// Addon Cover
          FormTextField(
            label: 'Addon Cover',
            hint: 'Enter Addon Cover',
            required: true,
            controller: _addOnCoverCtrl,
          ),
          const SizedBox(height: 16),

          /// Addon Sapphire Plus
          FormTextField(
            label: 'Addon Saphire Plus',
            hint: 'Enter Addon Saphire Plus',
            required: true,
            controller: _addOnSapphireCtrl,
          ),
          const SizedBox(height: 16),

          /// Upload Document
          FileUploadField(
            label: 'Upload Quotation Document',
            allowedExtensions: ['pdf', 'xls', 'xlsx', 'docx', 'jpg', 'png'],
            onFileSelected: (file) {
              uploadedQuotationFile = file; // 🔴 THIS is required
            },
          ),
          const SizedBox(height: 16),

          /// Comments
          const FormTextField(
            label: 'Comments',
            hint: 'Enter Comments',
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          /// View Document
          DropdownField(
            label: 'View Document',
            hints: 'Select Document',
            items: const ['User Quotation Document'],
            onChanged: (value) {
              setState(() {
                selectedDocumentName = value;
              });
            },
            required: false,
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottom: ActionButtonPair(
        primaryText: 'Approve',
        secondaryText: 'Reject',
        primaryValidator: _validateBeforeApprove,
        onPrimaryAction: _handleApprove,
        onSecondaryAction: _handleReject,
      )

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
          widget.request.requestId ?? 'CAR2025242',
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
  // Action button actual functions
  Future<void> _handleReject() async {
    final request = widget.request;
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

  Future<void> _handleUpload() async {
    try {
      final docReqBody = _bindUploadDocRequestBody();

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      await _client.uploadDocument(
        body: docReqBody,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      setState(() {
        _isUploading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });

      // ⛔ propagate failure to caller
      rethrow;
    }
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

  Future<void> _handleApprove() async {
    final requestId = widget.request.requestId;

    if (requestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing request')),
      );
      return;
    }

    try {
      // ---------------- STEP 1: Upload document ----------------
      await _handleUpload();

      // ---------------- STEP 2: Submit for approval ----------------
      final response = await _client.SubmitForInsuranceQuoteApproval(
        requestId: requestId,
        baseInsurance: int.tryParse(_baseInsuranceCtrl.text.trim()) ?? 0,
        addOnTataPower: int.tryParse(_addOnCoverCtrl.text.trim()) ?? 0,
        addOnSapphirePlus:
        int.tryParse(_addOnSapphireCtrl.text.trim()) ?? 0,
        commentsByGIT: (_commentsCtrl.text.trim().isEmpty)
            ? 'null'
            : _commentsCtrl.text.trim(),
      );

      if (!mounted) return;

      // ---------------- SUCCESS ----------------
      _showSnackBar(
        context: context,
        message: 'Document uploaded & approval submitted successfully',
        isSuccess: true,
      );

      Navigator.pop(context, response);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _getCommentsByRequestId() async {
    final request = widget.request;
    final requestId = request.requestId;

    if (requestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing request or employee details')),
      );
      return;
    }

    try {
      final response = await _client.getCommentsByRequestId(
        requestId: requestId,
      );

      setState(() {
        commentsOnInsurance = response.data?.commentsAssignedToEsna ?? 'NULL';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  bool _validateBeforeApprove() {
    final baseText = _baseInsuranceCtrl.text.trim();
    final tataText = _addOnCoverCtrl.text.trim();
    final sapphireText = _addOnSapphireCtrl.text.trim();

    // 1️⃣ Check if all fields are empty
    if (baseText.isEmpty &&
        tataText.isEmpty &&
        sapphireText.isEmpty) {
      _showSnackBar(
        context: context,
        message: 'Please enter at least one insurance amount',
        isSuccess: false,
      );
      return false;
    }

    // 2️⃣ Validate numeric values
    final baseInsurance = int.tryParse(baseText);
    final tataPower = int.tryParse(tataText);
    final sapphirePlus = int.tryParse(sapphireText);

    if (baseText.isNotEmpty && baseInsurance == null) {
      _showSnackBar(
        context: context,
        message: 'Base Insurance must be a valid number',
        isSuccess: false,
      );
      return false;
    }

    if (tataText.isNotEmpty && tataPower == null) {
      _showSnackBar(
        context: context,
        message: 'Tata Power Add-on must be a valid number',
        isSuccess: false,
      );
      return false;
    }

    if (sapphireText.isNotEmpty && sapphirePlus == null) {
      _showSnackBar(
        context: context,
        message: 'Sapphire Plus Add-on must be a valid number',
        isSuccess: false,
      );
      return false;
    }

    // 3️⃣ Ensure at least one value is greater than zero
    if ((baseInsurance ?? 0) <= 0 &&
        (tataPower ?? 0) <= 0 &&
        (sapphirePlus ?? 0) <= 0) {
      _showSnackBar(
        context: context,
        message: 'At least one insurance amount must be greater than 0',
        isSuccess: false,
      );
      return false;
    }

    return true; // 🔥 Safe to proceed
  }

}
