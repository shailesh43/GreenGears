import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../network/api_models/car_request.dart';
import '../../core/utils/enum.dart';
import '../../network/api_client.dart';
import '../widgets/form_detail_row.dart';
import '../widgets/form_text_field.dart';
import '../widgets/file_uploader.dart';
import '../widgets/drop_down.dart';
import '../widgets/action_button_pair.dart';
import './base_modal.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RequestVerificationModal extends StatefulWidget {
  final CarRequest request;
  final BuildContext parentContext;

  const RequestVerificationModal({
    super.key,
    required this.parentContext,
    required this.request,
  });

  @override
  State<RequestVerificationModal> createState() =>
      _RequestVerificationModalState();
}

class _RequestVerificationModalState extends State<RequestVerificationModal> {
  final ApiClient _client = ApiClient();

  // Form Controllers
  final _commentsCtrl = TextEditingController();

  // Form State
  String? selectedDocumentName;
  String? commentsOnEsnaReqVerif;

  // Document Upload State
  PlatformFile? uploadedDocumentFile;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCommentsByRequestId();
    });
  }

  @override
  void dispose() {
    _commentsCtrl.dispose();
    super.dispose();
  }

  // ==================== REQUEST BODY BUILDERS ====================

  /// Prepares the document upload payload
  Map<String, dynamic> _bindUploadDocRequestBody() {
    if (uploadedDocumentFile == null) {
      throw Exception('No file selected');
    }

    return {
      'emp_id': widget.request.empId.toString(),
      'process_stage': (Stage.assignedToEsna?.stageNo ?? 21).toString(),
      'doc_id': (Document.esnaUploadDoc?.docId ?? 2).toString(),
      'files': [
        MultipartFile.fromBytes(
          uploadedDocumentFile!.bytes!,
          filename: uploadedDocumentFile!.name,
        ),
      ],
    };
  }

  // ==================== VALIDATION ====================

  /// Validates all required fields before approval
  bool _validateBeforeApprove() {
    // Comments validation
    if (_commentsCtrl.text.trim().isEmpty) {
      _showValidationToast(
        'Please enter your comments'
      );
      return false;
    }
    return true;
  }

  // ==================== SUBMISSION HANDLERS ====================

  /// Handles document upload with progress tracking
  Future<void> _handleUpload() async {
    // Skip if no document selected
    if (uploadedDocumentFile == null) {
      _showSnackBar(
        message: 'Missing request or ES&A details',
        isSuccess: false,
      );
      return;
    }

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

      // Propagate failure to caller
      rethrow;
    }
  }

  /// Handles approval action
  Future<void> _handleApprove() async {
    final requestId = widget.request.requestId;
    final empId = widget.request.empId;

    if (requestId == null || empId == null) {
      _showSnackBar(
        message: 'Missing request or ES&A details',
        isSuccess: false,
      );
      return;
    }

    try {
      // STEP 1: Upload document if file is selected
      await _handleUpload();

      // STEP 2: Assign to insurance
      final response = await _client.assignToInsurance(
        requestId: requestId,
        empId: empId,
        commentsAssignedToEsna: _commentsCtrl.text.trim(),
      );

      if (!mounted) return;

      // Success feedback
      Navigator.pop(context, 'approved');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context, 'rejected');

    }
  }

  /// Handles rejection action
  Future<void> _handleReject() async {
    final request = widget.request;
    final requestId = request.requestId;
    final empId = request.empId;

    if (requestId == null || requestId.isEmpty || empId == null || empId.isEmpty) {
      _showSnackBar(
        message: 'Missing request or employee details',
        isSuccess: false,
      );
      return;
    }

    try {
      final response = await _client.decrementStageOnReject(
        requestId: requestId,
        empId: empId,
      );

      if (!mounted) return;

      Navigator.pop(context, response);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // ==================== DATA FETCHING ====================

  /// Fetches comments from previous stage
  Future<void> _getCommentsByRequestId() async {
    final request = widget.request;
    final requestId = request.requestId;

    if (requestId == null) {
      _showSnackBar(
        message: 'Missing request details',
        isSuccess: false,
      );
      return;
    }

    try {
      final response = await _client.getCommentsByRequestId(
        requestId: requestId,
      );

      if (!mounted) return;

      setState(() {
        commentsOnEsnaReqVerif = response.data?.commentsByUser ?? 'NULL';
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
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

  void _showValidationToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 4,   // ⬅ increase duration (default ~2 sec)
      backgroundColor: const Color(0xFFFFE3E3),
      textColor: const Color(0xFFFA6262),
      fontSize: 14.0,
    );
  }

  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      request: widget.request,
      title: 'Request Verification',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Request Details
          DetailRow(
            label: 'Request ID',
            value: widget.request.requestId ?? 'NULL',
          ),
          DetailRow(
            label: 'Employee ID',
            value: widget.request.empId ?? 'NULL',
          ),
          DetailRow(
            label: 'Employee Name',
            value: widget.request.employeeName ?? 'NULL',
          ),
          DetailRow(
            label: 'Contact',
            value: widget.request.contact ?? 'NULL',
          ),
          DetailRow(
            label: 'Email',
            value: widget.request.email?.toLowerCase() ?? 'NULL',
          ),
          DetailRow(
            label: 'Date Of Request',
            value: widget.request.updatedTime != null
                ? DateFormat('dd/MM/yyyy').format(widget.request.updatedTime!)
                : 'NULL',
          ),
          DetailRow(
            label: 'Grade',
            value: widget.request.grade ?? 'NULL',
          ),
          DetailRow(
            label: 'Eligibility',
            value: widget.request.eligibility?.toString() ?? 'NULL',
          ),
          DetailRow(
            label: 'Cost Center',
            value: widget.request.costCentre ?? 'NULL',
          ),
          DetailRow(
            label: 'Vehicle Model',
            value: widget.request.carModel ?? 'NULL',
          ),
          DetailRow(
            label: 'Manufactured by',
            value: widget.request.manufacturer ?? 'NULL',
          ),
          DetailRow(
            label: 'Vehicle Type',
            value: widget.request.vehicleType ?? 'NULL',
          ),
          DetailRow(
            label: 'Color',
            value: widget.request.colorChoice ?? 'NULL',
          ),
          DetailRow(
            label: 'Quotation',
            value: widget.request.quotation?.toString() ?? 'NULL',
          ),
          DetailRow(
            label: 'Comments by Employee',
            value: commentsOnEsnaReqVerif ?? 'NULL',
          ),
          const SizedBox(height: 24),

          // ES&A Comments Input
          FormTextField(
            label: 'ES&A Comments',
            hint: 'Enter Your Comments',
            maxLines: 3,
            controller: _commentsCtrl,
            required: true,
          ),
          const SizedBox(height: 16),

          // Document Upload
          FileUploadField(
            label: 'Upload Document - File Type Allowed: .pdf/.txt/.docx',
            allowedExtensions: const ['pdf', 'txt', 'doc', 'docx'],
            onFileSelected: (file) {
              setState(() {
                uploadedDocumentFile = file;
              });
            },
          ),
          const SizedBox(height: 16),

          // View Document Dropdown
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
          _showSnackBar(
            message: '${widget.request.requestId}: Request Approved',
            isSuccess: true,
          );
        },
        onSecondaryAction: () async {
          await _handleReject();

          _showSnackBar(
            message: '${widget.request.requestId}: Request Rejected',
            isSuccess: true,
          );
        },
      ),

    );
  }
}