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

class RtoTaxReceiptModal extends StatefulWidget {
  final CarRequest request;

  RtoTaxReceiptModal({
    super.key,
    required this.request
  });

  @override
  State<RtoTaxReceiptModal> createState() => _RtoTaxReceiptModalState();

}

class _RtoTaxReceiptModalState extends State<RtoTaxReceiptModal> {
  String? selectedDocumentName;
  final ApiClient _client = ApiClient();
  final _commentsCtrl = TextEditingController();

  String? commentsOnEsnaRto;
  List<UploadedFileModel> uploadedDocs = [];
  List<Document> documentList = [];
  Document? selectedDocument;

  // Form field controllers
  final _vehicleNumberCtrl = TextEditingController();
  final _chassisNumberCtrl = TextEditingController();
  final _engineNumberCtrl = TextEditingController();
  final _fastTagNumberCtrl = TextEditingController();
  final _vehicleHandoverDateCtrl = TextEditingController();


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
      _getDocumentsByRequestId();
    });
  }

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
          DetailRow(label: 'Comments by ES&A', value: commentsOnEsnaRto?.toString() ?? 'NULL'),

          const SizedBox(height: 16),
          FormTextField(
            label: 'Vehicle Number',
            hint: 'Enter Vehicle number',
            required: true,
            controller: _vehicleNumberCtrl,
          ),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Chassis Number',
            hint: 'Enter Chassis number',
            required: true,
            controller: _chassisNumberCtrl,
          ),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Engine Number',
            hint: 'Enter Engine number',
            required: true,
            controller: _engineNumberCtrl,
          ),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Fastag Number',
            hint: 'Enter Fastag Number',
            required: true,
            controller: _fastTagNumberCtrl,
          ),
          const SizedBox(height: 16),
          DatePickerField(
            label: 'Vehicle Handover Date',
            controller: _vehicleHandoverDateCtrl,
          ),
          const SizedBox(height: 16),
          const FileUploadField(label: 'Upload Files'),
          const SizedBox(height: 16),
          DropdownField(
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
            required: true,
          ),
          const SizedBox(height: 16),
          FormTextField(label: 'Comments', hint: 'Your Comments', required: true, maxLines: 3, controller: _commentsCtrl,),
          const SizedBox(height: 24),
        ],
      ),
      bottom: ActionButtonPair(
        primaryText: 'Approve',
        secondaryText: 'Reject',
        primaryValidator: _validateBeforeApprove,
        onPrimaryAction: _handleApprove,
        onSecondaryAction: _handleReject,
      ),
    );
  }

  Future<void> _handleApprove() async {
    final requestId = widget.request.requestId;
    final empId = widget.request.empId;

    if (requestId == null || empId == null ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing request or ES&A details')),
      );
      return;
    }

    try {
      // ---------------- STEP 1: Upload document ----------------
      await _handleUpload();

      // ---------------- STEP 2: Submit for approval ----------------
      final response = await _client.submitByEsnaRtoTaxReceipt(
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

      Navigator.pop(context, response); // success close
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _handleReject() async {
    final request = widget.request;
    final requestId = request.requestId;
    final empId = request.empId;

    if (requestId == null ||
        requestId.isEmpty ||
        empId == null ||
        empId.isEmpty) {
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

      Navigator.pop(context, response);
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
        commentsOnEsnaRto = response.data?.commentsRtoTaxReceiptOtherDocsEsna ?? 'NULL';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _getDocumentsByRequestId() async {
    final requestId = widget.request.requestId;

    if (requestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing request or employee details')),
      );
      return;
    }

    try {
      final response = await _client.getAllUploadedDocsFromS3(
        requestId: requestId,
      );

      final docs = response.data; // List<UploadedDocData>

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  bool _validateBeforeApprove() {
    final vehicleNumber = _vehicleNumberCtrl.text.trim();
    final chassisNumber = _chassisNumberCtrl.text.trim();
    final engineNumber = _engineNumberCtrl.text.trim();
    final fastTagNumber = _fastTagNumberCtrl.text.trim();
    final vehicleHandoverDate = _vehicleHandoverDateCtrl.text.trim();
    final comments = _commentsCtrl.text.trim();

    // 1️⃣ Check vehicle number
    if (vehicleNumber.isEmpty) {
      _showSnackBar(
        context: context,
        message: 'Vehicle Number is required',
        isSuccess: false,
      );
      return false;
    }

    // 2️⃣ Check chassis number
    if (chassisNumber.isEmpty) {
      _showSnackBar(
        context: context,
        message: 'Chassis Number is required',
        isSuccess: false,
      );
      return false;
    }

    // 3️⃣ Check engine number
    if (engineNumber.isEmpty) {
      _showSnackBar(
        context: context,
        message: 'Engine Number is required',
        isSuccess: false,
      );
      return false;
    }

    // 4️⃣ Check fastag number
    if (fastTagNumber.isEmpty) {
      _showSnackBar(
        context: context,
        message: 'Fastag Number is required',
        isSuccess: false,
      );
      return false;
    }

    // 5️⃣ Check vehicle handover date
    if (vehicleHandoverDate.isEmpty) {
      _showSnackBar(
        context: context,
        message: 'Vehicle Handover Date is required',
        isSuccess: false,
      );
      return false;
    }

    // 6️⃣ Check comments
    if (comments.isEmpty) {
      _showSnackBar(
        context: context,
        message: 'Comments are required before approving',
        isSuccess: false,
      );
      return false;
    }

    return true; // 🔥 Safe to proceed
  }

}