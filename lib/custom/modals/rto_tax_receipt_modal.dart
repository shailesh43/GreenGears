import 'dart:core';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../network/api_client.dart';
import '../../core/utils/enum.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_models/get_all_docs_response_model.dart';

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
  List<UploadedDocData> uploadedDocs = [];
  List<Document> documentList = [];
  Document? selectedDocument;

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

          const SizedBox(height: 16),
          const FormTextField(label: 'Vehicle Number', hint: 'Enter Vehicle number', required: true,),
          const SizedBox(height: 16),
          const FormTextField(label: 'Chassis Number', hint: 'Enter Chassis number', required: true,),
          const SizedBox(height: 16),
          const FormTextField(label: 'Engine Number', hint: 'Enter Engine number', required: true,),
          const SizedBox(height: 16),
          const FormTextField(label: 'Fastag Number', hint: 'Enter Fastag Number', required: true,),
          const SizedBox(height: 16),
          const DatePickerField(label: 'Vehicle Handover Date'),
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
        primaryMessage: '${widget.request.requestId} Request Approved',
        secondaryMessage: '${widget.request.requestId} Request Rejected',
        onPrimaryAction: () => _handleApprove(),
        onSecondaryAction: () => _handleReject(),
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
      final response = await _client.submitByEsnaRtoTaxReceipt(
        requestId: requestId,
        empId: empId,
        commentsAssignedToEsna: _commentsCtrl.text.trim(),
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
        commentsOnEsnaRto = response.data?.commentsEmiUserApproval ?? 'NULL';
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

}