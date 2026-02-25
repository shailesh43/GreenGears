import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../network/api_models/car_request.dart';
import '../../core/utils/enum.dart';
import '../../network/api_client.dart';
import '../../network/api_models/get_all_docs_response_model.dart';
import '../../network/api_models/uploaded_file_model.dart';
import '../widgets/form_detail_row.dart';
import '../widgets/form_text_field.dart';
import '../widgets/file_uploader.dart';
import '../widgets/drop_down.dart';
import '../widgets/action_button_pair.dart';
import './base_modal.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/helpers/file_downloader.dart';

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
  // String? selectedDocumentName;
  String? commentsOnEsnaReqVerif;

  // Document state
  List<UploadedFileModel> uploadedDocs = [];
  List<Document> documentList = [];
  Document? selectedDocument;

  // Document Upload State
  PlatformFile? uploadedDocumentFile;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    // 1️⃣ Fetch comments and documents after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCommentsByRequestId();
      _getDocumentsByRequestId();
    });

    // 2️⃣ Listen to comments controller to reset error border on typing
    _commentsCtrl.addListener(() {
      if (_commentsErrorText != null && _commentsCtrl.text.trim().isNotEmpty) {
        setState(() {
          _commentsErrorText = null; // reset error as soon as user types
        });
      }
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
  String? _commentsErrorText;
  bool _validateBeforeApprove() {
    if (_commentsCtrl.text.trim().isEmpty) {
      setState(() {
        _commentsErrorText = 'Required'; // shows inline error
      });
      _showValidationToast('Please enter comments');
      return false;
    }
    if (uploadedDocumentFile == null) {
      _showValidationToast('Please upload a document');
      return false;
    }
    return true;
  }

  // ==================== SUBMISSION HANDLERS ====================

  /// Handles document upload with progress tracking
  Future<void> _handleUpload() async {
    // Skip if no document selected
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
    final request = widget.request;
    final requestId = request.requestId!;
    final empId = request.empId!;

    try {
      // STEP 1: Assign to insurance
      final response = await _client.assignToInsurance(
        requestId: requestId,
        empId: empId,
        commentsAssignedToEsna: _commentsCtrl.text.trim(),
      );
      // STEP 2: Upload document if file is selected
      await _handleUpload();
      // Success feedback

      if (!mounted) return;
      Navigator.pop(context, 'Request approved');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context, 'Request failed');

    }
  }

  /// Handles rejection action
  Future<void> _handleReject() async
  {
    final request = widget.request;
    final requestId = request.requestId;
    final empId = request.empId;

    if (requestId == null || requestId.isEmpty || empId == null || empId.isEmpty) {
      _showValidationToast('Missing request or employee details');
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
    }
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

  void _showValidationToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 3,
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
            value: commentsOnEsnaReqVerif ?? '-',
          ),
          const SizedBox(height: 24),

          // ES&A Comments Input
          FormTextField(
            label: 'ES&A Comments',
            hint: 'Enter Your Comments',
            maxLines: 3,
            controller: _commentsCtrl,
            required: true,
            errorText: _commentsErrorText,
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