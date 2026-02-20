import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Custom
import '../widgets/form_detail_row.dart';
import '../widgets/form_text_field.dart';
import '../widgets/file_uploader.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/action_button_pair.dart';
import '../widgets/drop_down.dart';
import './base_modal.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../network/api_client.dart';
import '../../core/utils/enum.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_models/get_all_docs_response_model.dart';
import '../../network/api_models/uploaded_file_model.dart';
import '../../core/helpers/file_downloader.dart';


class PaymentDetailsModal extends StatefulWidget {
  final CarRequest request;

  const PaymentDetailsModal({
    super.key,
    required this.request,
  });

  @override
  State<PaymentDetailsModal> createState() => _PaymentDetailsModalState();
}

class _PaymentDetailsModalState extends State<PaymentDetailsModal> {
  final ApiClient _client = ApiClient();

  // Form Controllers
  final _commentsCtrl = TextEditingController();
  final _poNumberCtrl = TextEditingController();
  final _poDateCtrl = TextEditingController();
  final _disbursementAmountCtrl = TextEditingController();
  final _paymentDateCtrl = TextEditingController();
  final _utrCodeCtrl = TextEditingController();

  // Fetched data
  String? commentsOnEsnaPayment;

  // Document state
  List<UploadedFileModel> uploadedDocs = [];
  List<Document> documentList = [];
  Document? selectedDocument;

  // Document Upload State
  PlatformFile? uploadedDocumentFile;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  Map<String, dynamic> _bindUploadDocRequestBody() {
    if (uploadedDocumentFile == null) {
      throw Exception('No file selected');
    }

    return {
      'emp_id': widget.request.empId.toString(),
      'process_stage': (Stage.requested?.stageNo ?? 20).toString(),
      'doc_id': (Document.rtoTaxReceiptDoc?.docId ?? 8).toString(),
      'files': [
        MultipartFile.fromBytes(
          uploadedDocumentFile!.bytes!,
          filename: uploadedDocumentFile!.name,
        ),
      ],
    };
  }

  // Inline error texts for required FormTextFields
  String? _poNumberErrorText;
  String? _disbursementAmountErrorText;
  String? _utrCodeErrorText;
  String? _commentsErrorText;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCommentsByRequestId();
      _getDocumentsByRequestId();
    });

    // Clear inline errors as soon as user types in each required field
    _poNumberCtrl.addListener(() {
      if (_poNumberErrorText != null && _poNumberCtrl.text.trim().isNotEmpty) {
        setState(() => _poNumberErrorText = null);
      }
    });

    _disbursementAmountCtrl.addListener(() {
      if (_disbursementAmountErrorText != null &&
          _disbursementAmountCtrl.text.trim().isNotEmpty) {
        setState(() => _disbursementAmountErrorText = null);
      }
    });

    _utrCodeCtrl.addListener(() {
      if (_utrCodeErrorText != null && _utrCodeCtrl.text.trim().isNotEmpty) {
        setState(() => _utrCodeErrorText = null);
      }
    });

    _commentsCtrl.addListener(() {
      if (_commentsErrorText != null && _commentsCtrl.text.trim().isNotEmpty) {
        setState(() => _commentsErrorText = null);
      }
    });
  }

  @override
  void dispose() {
    _commentsCtrl.dispose();
    _poNumberCtrl.dispose();
    _poDateCtrl.dispose();
    _disbursementAmountCtrl.dispose();
    _paymentDateCtrl.dispose();
    _utrCodeCtrl.dispose();
    super.dispose();
  }

  // ==================== VALIDATION ====================

  bool _validateBeforeApprove() {
    bool isValid = true;

    setState(() {
      _poNumberErrorText =
      _poNumberCtrl.text.trim().isEmpty ? 'Required' : null;
      _disbursementAmountErrorText =
      _disbursementAmountCtrl.text.trim().isEmpty ? 'Required' : null;
      _utrCodeErrorText =
      _utrCodeCtrl.text.trim().isEmpty ? 'Required' : null;
      _commentsErrorText =
      _commentsCtrl.text.trim().isEmpty ? 'Required' : null;

      if (_poNumberCtrl.text.trim().isEmpty ||
          _disbursementAmountCtrl.text.trim().isEmpty ||
          _utrCodeCtrl.text.trim().isEmpty ||
          _commentsCtrl.text.trim().isEmpty) {
        isValid = false;
      }
    });

    return isValid;
  }

  // ==================== SUBMISSION HANDLERS ====================

  Future<void> _handleUpload() async {
    if (uploadedDocumentFile == null) return;

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

  /// Pure API worker – no Navigator.pop, no snackbars.
  Future<void> _handleApprove() async {
    final requestId = widget.request.requestId;
    final empId = widget.request.empId;

    if (requestId == null || empId == null) return;

    await _client.submitByEsnaPayment(
      requestId: requestId,
      empId: empId,
      commentsAssignedToEsna: _commentsCtrl.text.trim(),
      poNumber: _poNumberCtrl.text.trim(),
      poDateOfIssue: _poDateCtrl.text.trim(),
      disbursementAmount: _disbursementAmountCtrl.text.trim(),
      paymentDate: _paymentDateCtrl.text.trim(),
      utr: _utrCodeCtrl.text.trim(),
    );
  }

  /// Pure API worker – no Navigator.pop, no snackbars.
  Future<void> _handleReject() async {
    final requestId = widget.request.requestId;
    final empId = widget.request.empId;

    if (requestId == null || requestId.isEmpty || empId == null || empId.isEmpty) return;

    await _client.decrementStageOnReject(
      requestId: requestId,
      empId: empId,
    );
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
        commentsOnEsnaPayment =
            response.data?.commentsEmiUserApproval ?? 'NULL';
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
      title: 'Payment Details',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Request Details
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
          DetailRow(
            label: 'EMI approval comments',
            value: commentsOnEsnaPayment ?? 'NULL',
          ),
          const SizedBox(height: 16),

          // Input Fields
          FormTextField(
            label: 'PO Number',
            hint: 'Enter Purchase Order No',
            required: true,
            controller: _poNumberCtrl,
            errorText: _poNumberErrorText,
          ),
          const SizedBox(height: 16),
          DatePickerField(label: 'PO Date', controller: _poDateCtrl),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Disbursement Amount',
            hint: 'Enter Disbursement amount',
            required: true,
            controller: _disbursementAmountCtrl,
            errorText: _disbursementAmountErrorText,
          ),
          const SizedBox(height: 16),
          DatePickerField(label: 'Payment Date', controller: _paymentDateCtrl),
          const SizedBox(height: 16),
          FormTextField(
            label: 'UTR',
            hint: 'Enter UTR code',
            required: true,
            controller: _utrCodeCtrl,
            errorText: _utrCodeErrorText,
          ),
          const SizedBox(height: 16),
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
            maxLines: 3,
            required: true,
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
          if (!mounted) return;
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