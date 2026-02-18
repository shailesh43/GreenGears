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
  final BuildContext parentContext;

  const InsuranceScreenModal({
    super.key,
    required this.parentContext,
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

  // Inline error texts for required FormTextFields
  String? _baseInsuranceErrorText;
  String? _addOnCoverErrorText;
  String? _addOnSapphireErrorText;

  // Document upload & progress
  PlatformFile? uploadedQuotationFile;
  double _uploadProgress = 0.0; // 0.0 → 1.0 for LinearProgressIndicator
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

    // Fetch comments after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCommentsByRequestId();
    });

    // Clear inline error as soon as user types in Base Insurance
    _baseInsuranceCtrl.addListener(() {
      if (_baseInsuranceErrorText != null &&
          _baseInsuranceCtrl.text.trim().isNotEmpty) {
        setState(() {
          _baseInsuranceErrorText = null;
        });
      }
    });

    // Clear inline error as soon as user types in Addon Cover
    _addOnCoverCtrl.addListener(() {
      if (_addOnCoverErrorText != null &&
          _addOnCoverCtrl.text.trim().isNotEmpty) {
        setState(() {
          _addOnCoverErrorText = null;
        });
      }
    });

    // Clear inline error as soon as user types in Addon Sapphire Plus
    _addOnSapphireCtrl.addListener(() {
      if (_addOnSapphireErrorText != null &&
          _addOnSapphireCtrl.text.trim().isNotEmpty) {
        setState(() {
          _addOnSapphireErrorText = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _baseInsuranceCtrl.dispose();
    _addOnCoverCtrl.dispose();
    _addOnSapphireCtrl.dispose();
    _commentsCtrl.dispose();
    super.dispose();
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
            errorText: _baseInsuranceErrorText,
          ),
          const SizedBox(height: 16),

          /// Addon Cover
          FormTextField(
            label: 'Addon Cover',
            hint: 'Enter Addon Cover',
            required: true,
            controller: _addOnCoverCtrl,
            errorText: _addOnCoverErrorText,
          ),
          const SizedBox(height: 16),

          /// Addon Sapphire Plus
          FormTextField(
            label: 'Addon Saphire Plus',
            hint: 'Enter Addon Saphire Plus',
            required: true,
            controller: _addOnSapphireCtrl,
            errorText: _addOnSapphireErrorText,
          ),
          const SizedBox(height: 16),

          /// Upload Document
          FileUploadField(
            label: 'Upload Quotation Document',
            allowedExtensions: ['pdf', 'xls', 'xlsx', 'docx', 'jpg', 'png'],
            onFileSelected: (file) {
              setState(() {
                uploadedQuotationFile = file;
              });
            },
          ),
          const SizedBox(height: 16),

          /// Comments (not required — no errorText)
          FormTextField(
            label: 'Comments',
            hint: 'Enter Comments',
            maxLines: 3,
            controller: _commentsCtrl,
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
        primaryValidator: () {
          return _validateBeforeApprove();
        },
        onPrimaryAction: () async {
          await _handleApprove();
          // if (!mounted) return;
          _showSnackBar(
            message: '${widget.request.requestId}: Request Approved',
            isSuccess: true,
          );
          // Navigator.pop(context);
        },
        onSecondaryAction: () async {
          await _handleReject();
          // if (!mounted) return;
          _showSnackBar(
            message: '${widget.request.requestId}: Request Rejected',
            isSuccess: true,
          );
          // Navigator.pop(context);
        },
      ),
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

  // ==================== SUBMISSION HANDLERS ====================

  Future<void> _handleReject() async {
    final requestId = widget.request.requestId;
    final empId = widget.request.empId;

    if (requestId == null || requestId.isEmpty || empId == null || empId.isEmpty) return;

    await _client.decrementStageOnReject(
      requestId: requestId,
      empId: empId,
    );
  }

  Future<void> _handleUpload() async {
    // Skip silently if no document selected — upload is optional
    if (uploadedQuotationFile == null) return;

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

      // ⛔ Propagate failure to caller
      rethrow;
    }
  }

  Future<void> _handleApprove() async {
    final requestId = widget.request.requestId;
    if (requestId == null) return;
    try
    {
    // ---------------- STEP 1: Upload document (if selected) ----------------
    await _handleUpload();

    // ---------------- STEP 2: Submit for insurance quote approval ----------------
    await _client.SubmitForInsuranceQuoteApproval(
      requestId: requestId,
      baseInsurance: int.tryParse(_baseInsuranceCtrl.text.trim()) ?? 0,
      addOnTataPower: int.tryParse(_addOnCoverCtrl.text.trim()) ?? 0,
      addOnSapphirePlus: int.tryParse(_addOnSapphireCtrl.text.trim()) ?? 0,
      commentsByGIT: _commentsCtrl.text.trim().isEmpty
          ? 'Approved'
          : _commentsCtrl.text.trim(),
    );
    if (!mounted) return;
    Navigator.pop(context, 'Request approved');
    }
    catch(e){
      if (!mounted) return;
      Navigator.pop(context, 'Request failed');
    }
  }

  // ==================== DATA FETCHING ====================

  Future<void> _getCommentsByRequestId() async {
    final requestId = widget.request.requestId;
    if (requestId == null) return;

    try {
      final response = await _client.getCommentsByRequestId(
        requestId: requestId,
      );

      if (!mounted) return;

      setState(() {
        commentsOnInsurance = response.data?.commentsAssignedToEsna ?? 'NULL';
      });
    } catch (_) {}
  }

  // ==================== VALIDATION ====================

  bool _validateBeforeApprove() {
    final baseText = _baseInsuranceCtrl.text.trim();
    final tataText = _addOnCoverCtrl.text.trim();
    final sapphireText = _addOnSapphireCtrl.text.trim();

    bool isValid = true;

    setState(() {
      _baseInsuranceErrorText =
      baseText.isEmpty ? 'Required' : null;

      _addOnCoverErrorText =
      tataText.isEmpty ? 'Required' : null;

      _addOnSapphireErrorText =
      sapphireText.isEmpty ? 'Required' : null;

      // If any one is empty → invalid
      if (baseText.isEmpty ||
          tataText.isEmpty ||
          sapphireText.isEmpty) {
        isValid = false;
      }
    });

    return isValid;
  }

  // ==================== UI HELPERS ====================

  void _showSnackBar({
    required String message,
    required bool isSuccess,
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
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