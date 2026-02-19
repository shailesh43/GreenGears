import 'dart:core';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../network/api_client.dart';
import '../../core/utils/enum.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_models/get_all_docs_response_model.dart';
import '../../network/api_models/uploaded_file_model.dart';
import 'package:file/file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

// Customs
import '../widgets/action_button_pair.dart';
import '../widgets/form_detail_row.dart';
import '../widgets/form_text_field.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/file_uploader.dart';
import '../widgets/drop_down.dart';
import './base_modal.dart';
import '../../core/helpers/file_downloader.dart';

class RtoTaxReceiptModal extends StatefulWidget {
  final CarRequest request;

  const RtoTaxReceiptModal({
    super.key,
    required this.request,
  });

  @override
  State<RtoTaxReceiptModal> createState() => _RtoTaxReceiptModalState();
}

class _RtoTaxReceiptModalState extends State<RtoTaxReceiptModal> {
  final ApiClient _client = ApiClient();

  // Form Controllers
  final _commentsCtrl = TextEditingController();
  final _vehicleNumberCtrl = TextEditingController();
  final _chassisNumberCtrl = TextEditingController();
  final _engineNumberCtrl = TextEditingController();
  final _fastTagNumberCtrl = TextEditingController();
  final _vehicleHandoverDateCtrl = TextEditingController();

  // Fetched data
  String? commentsOnEsnaRto;
  List<UploadedFileModel> uploadedDocs = [];
  List<Document> documentList = [];
  Document? selectedDocument;

  // Inline error texts for required FormTextFields
  String? _vehicleNumberErrorText;
  String? _chassisNumberErrorText;
  String? _engineNumberErrorText;
  String? _fastTagNumberErrorText;
  String? _commentsErrorText;

  // Document upload & progress
  PlatformFile? uploadedQuotationFile;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  Map<String, dynamic> _bindUploadDocRequestBody() {
    if (uploadedQuotationFile == null) {
      throw Exception('No file selected');
    }

    return {
      'emp_id': widget.request.empId.toString(),
      'process_stage': (Stage.requested?.stageNo ?? 20).toString(),
      'doc_id': (Document.initialQuotationDoc?.docId ?? 1).toString(),
      'files': [
        MultipartFile.fromBytes(
          uploadedQuotationFile!.bytes!,
          filename: uploadedQuotationFile!.name,
        ),
      ],
    };
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCommentsByRequestId();
      _getDocumentsByRequestId();
    });

    _vehicleNumberCtrl.addListener(() {
      if (_vehicleNumberErrorText != null &&
          _vehicleNumberCtrl.text.trim().isNotEmpty) {
        setState(() => _vehicleNumberErrorText = null);
      }
    });

    _chassisNumberCtrl.addListener(() {
      if (_chassisNumberErrorText != null &&
          _chassisNumberCtrl.text.trim().isNotEmpty) {
        setState(() => _chassisNumberErrorText = null);
      }
    });

    _engineNumberCtrl.addListener(() {
      if (_engineNumberErrorText != null &&
          _engineNumberCtrl.text.trim().isNotEmpty) {
        setState(() => _engineNumberErrorText = null);
      }
    });

    _fastTagNumberCtrl.addListener(() {
      if (_fastTagNumberErrorText != null &&
          _fastTagNumberCtrl.text.trim().isNotEmpty) {
        setState(() => _fastTagNumberErrorText = null);
      }
    });

    _commentsCtrl.addListener(() {
      if (_commentsErrorText != null &&
          _commentsCtrl.text.trim().isNotEmpty) {
        setState(() => _commentsErrorText = null);
      }
    });
  }

  @override
  void dispose() {
    _commentsCtrl.dispose();
    _vehicleNumberCtrl.dispose();
    _chassisNumberCtrl.dispose();
    _engineNumberCtrl.dispose();
    _fastTagNumberCtrl.dispose();
    _vehicleHandoverDateCtrl.dispose();
    super.dispose();
  }

  // ==================== VALIDATION ====================

  bool _validateBeforeApprove() {
    bool isValid = true;

    setState(() {
      _vehicleNumberErrorText =
      _vehicleNumberCtrl.text.trim().isEmpty ? 'Required' : null;
      _chassisNumberErrorText =
      _chassisNumberCtrl.text.trim().isEmpty ? 'Required' : null;
      _engineNumberErrorText =
      _engineNumberCtrl.text.trim().isEmpty ? 'Required' : null;
      _fastTagNumberErrorText =
      _fastTagNumberCtrl.text.trim().isEmpty ? 'Required' : null;
      _commentsErrorText =
      _commentsCtrl.text.trim().isEmpty ? 'Required' : null;

      if (_vehicleNumberCtrl.text.trim().isEmpty ||
          _chassisNumberCtrl.text.trim().isEmpty ||
          _engineNumberCtrl.text.trim().isEmpty ||
          _fastTagNumberCtrl.text.trim().isEmpty ||
          _commentsCtrl.text.trim().isEmpty) {
        isValid = false;
      }
    });

    return isValid;
  }

  // ==================== SUBMISSION HANDLERS ====================

  /// Pure API worker — no Navigator.pop, no snackbars.
  Future<void> _handleApprove() async {
    final requestId = widget.request.requestId;
    final empId = widget.request.empId;

    if (requestId == null || empId == null) return;
    try {
      // STEP 1: Submit RTO tax receipt
      await _client.submitByEsnaRtoTaxReceipt(
        requestId: requestId,
        empId: empId,
        commentsAssignedToEsna: _commentsCtrl.text.trim(),
        vehicleNumber: _vehicleNumberCtrl.text.trim(),
        vehicleMake: widget.request.manufacturer ?? '',
        vehicleModel: widget.request.carModel ?? '',
        chassisNumber: _chassisNumberCtrl.text.trim(),
        engineNumber: _engineNumberCtrl.text.trim(),
        vehicleHandoverDate: _vehicleHandoverDateCtrl.text.trim(),
        fastTagNumber: _fastTagNumberCtrl.text.trim(),
      );

      // STEP 2: Upload document (silently skip if no file selected)
      await _handleUpload();
      if (!mounted) return;
      Navigator.pop(context, 'Request approved');
    }
    catch(e) {
      if (!mounted) return;
      Navigator.pop(context, 'Request failed');
    }
  }

  /// Pure API worker — no Navigator.pop, no snackbars.
  Future<void> _handleReject() async {
    final requestId = widget.request.requestId;
    final empId = widget.request.empId;

    if (requestId == null || requestId.isEmpty || empId == null || empId.isEmpty) return;

    await _client.decrementStageOnReject(
      requestId: requestId,
      empId: empId,
    );
  }

  /// Silently skips if no file selected — upload is optional.
  Future<void> _handleUpload() async {
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
          setState(() => _uploadProgress = progress);
        },
      );

      setState(() => _isUploading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      rethrow;
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
        commentsOnEsnaRto =
            response.data?.commentsPaymentDetailsEsna ?? 'NULL';
      });
    } catch (_) {}
  }

  Future<void> _getDocumentsByRequestId() async {
    final requestId = widget.request.requestId;
    if (requestId == null) return;

    try {
      final response = await _client.getAllUploadedDocsFromS3(
        requestId: requestId,
      );

      if (!mounted) return;

      final docs = response.data;

      final List<Document> docsEnumList = docs
          .map((e) => Document.fromDocId(e.docId ?? -1))
          .whereType<Document>()
          .toSet()
          .toList()
        ..sort((a, b) => a.docId.compareTo(b.docId));

      setState(() {
        uploadedDocs = docs;
        documentList = docsEnumList;
      });
    } catch (_) {}
  }

  // ==================== DOCUMENT HANDLING ====================

  /// Opens the selected document by finding the first file with matching docId
  /// and downloading it using the FileDownloader helper.
  void _openSelectedDocument() {
    if (selectedDocument == null) return;

    // Find the first uploaded file that matches the selected document type
    final file = uploadedDocs.firstWhere(
          (doc) => doc.docId == selectedDocument!.docId,
      orElse: () => throw Exception('No file found for selected document'),
    );

    FileDownloader.downloadAndOpenFile(
      context: context,
      presignedUrl: file.downloadUrl,
      rawFileName: file.fileName,
    );
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

  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      request: widget.request,
      title: 'RTO Tax Receipt',
      content: Column(
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
          DetailRow(label: 'Comments by ES&A', value: commentsOnEsnaRto ?? 'NULL'),
          const SizedBox(height: 16),

          FormTextField(
            label: 'Vehicle Number',
            hint: 'Enter Vehicle number',
            required: true,
            controller: _vehicleNumberCtrl,
            errorText: _vehicleNumberErrorText,
          ),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Chassis Number',
            hint: 'Enter Chassis number',
            required: true,
            controller: _chassisNumberCtrl,
            errorText: _chassisNumberErrorText,
          ),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Engine Number',
            hint: 'Enter Engine number',
            required: true,
            controller: _engineNumberCtrl,
            errorText: _engineNumberErrorText,
          ),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Fastag Number',
            hint: 'Enter Fastag Number',
            required: true,
            controller: _fastTagNumberCtrl,
            errorText: _fastTagNumberErrorText,
          ),
          const SizedBox(height: 16),
          DatePickerField(
            label: 'Vehicle Handover Date',
            controller: _vehicleHandoverDateCtrl,
          ),
          const SizedBox(height: 16),
          const FileUploadField(label: 'Upload Files'),
          const SizedBox(height: 16),

          // Document Viewer Dropdown with Download/View functionality
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: DropdownField(
                  label: 'View Document',
                  hints: 'Select Document',
                  items: documentList.map((e) => e.docLabel).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    final doc = documentList.firstWhere(
                          (e) => e.docLabel == value,
                      orElse: () => throw Exception('Document not found'),
                    );

                    setState(() {
                      selectedDocument = doc;
                    });
                  },
                  required: false,
                ),
              ),
              if (selectedDocument != null) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: GestureDetector(
                    onTap: _openSelectedDocument,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFDCDCDC),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.download,
                        color: Color(0xFF9A9A9A),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Comments',
            hint: 'Your Comments',
            required: true,
            maxLines: 3,
            controller: _commentsCtrl,
            errorText: _commentsErrorText,
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
          Navigator.pop(context);
        },
        onSecondaryAction: () async {
          await _handleReject();
          if (!mounted) return;
          _showSnackBar(
            message: '${widget.request.requestId}: Request Rejected',
            isSuccess: true,
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}