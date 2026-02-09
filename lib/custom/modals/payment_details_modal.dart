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

import '../../network/api_client.dart';
import '../../core/utils/enum.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_models/get_all_docs_response_model.dart';


class PaymentDetailsModal extends StatefulWidget {
  final CarRequest request;
  PaymentDetailsModal({
    super.key,
    required this.request
  });

  @override
  State<PaymentDetailsModal> createState() => _PaymentDetailsModalState();
}

class _PaymentDetailsModalState extends State<PaymentDetailsModal> {
  final ApiClient _client = ApiClient();
  final _commentsCtrl = TextEditingController();
  String? commentsOnEsnaPayment;

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
      title: 'Payment Details',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ES&A Data fields
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
          DetailRow(label: 'EMI approval comments', value: commentsOnEsnaPayment?.toString() ?? 'NULL'),

          const SizedBox(height: 16),

          // ES&A Input fields
          const FormTextField(label: 'PO Number', hint: 'Enter Purchase Order No', required: true,),
          const SizedBox(height: 16),
          const DatePickerField(label: 'PO Date'),
          const SizedBox(height: 16),
          const FormTextField(label: 'Disbursement Amount', hint: 'Enter Disbursement amount', required: true,),
          const SizedBox(height: 16),
          const DatePickerField(label: 'Payment Date'),
          const SizedBox(height: 16),
          const FormTextField(label: 'UTR', hint: 'Enter UTR code', required: true,),
          const SizedBox(height: 16),
          const FileUploadField(label: 'Upload Document'),
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
          FormTextField(label: 'Comments', hint: 'Your Comments', maxLines: 3, required: true, controller: _commentsCtrl,),
          const SizedBox(height: 24),
        ],
      ),
      bottom: ActionButtonPair(
        primaryText: 'Approve',
        secondaryText: 'Reject',
        primaryMessage: 'Request Approved',
        secondaryMessage: 'Request Rejected',
        onPrimaryAction: () => _handleApprove(),
        onSecondaryAction: () => _handleReject(),
      ),
    );
  }

  Future<void> _handleApprove() async {
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
      final response = await _client.submitByEsnaPayment(
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
        commentsOnEsnaPayment = response.data?.commentsEmiUserApproval ?? 'NULL';
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