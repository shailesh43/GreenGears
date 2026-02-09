import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/action_button_pair.dart';
import '../widgets/request_card.dart';
import '../widgets/form_detail_row.dart';
import '../widgets/drop_down.dart';
import './base_modal.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_models/list_of_esna_model.dart';
import '../../network/api_client.dart';
import '../../core/utils/enum.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_models/get_all_docs_response_model.dart';

class AssignEsnaCardModal extends StatefulWidget {
  final CarRequest request;
  final List<GetListOfEsnaModel> esnaList;

  const AssignEsnaCardModal({
    super.key,
    required this.request,
    required this.esnaList,
  });

  @override
  State<AssignEsnaCardModal> createState() =>
      _AssignEsnaCardModalState();
}

class _AssignEsnaCardModalState extends State<AssignEsnaCardModal> {
  final ApiClient _client = ApiClient();
  bool isLoading = false;

  Document? selectedDocumentName;
  String? selectedEsnaName;
  String? selectedEsnaEmpId;
  String? commentsByAdmin;

  List<UploadedDocData> uploadedDocs = [];
  List<Document> documentList = [];
  Document? selectedDocument;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getDocumentsByRequestId();
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;

    return BaseModal(
      request: request,
      title: request.requestId ?? '',
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

          const SizedBox(height: 24),
          /// ES&A Dropdown
          DropdownField(
            label: 'Assign ES&A to the Request',
            hints: 'Select ES&A',
            items: widget.esnaList
                .map((e) => e.shortName.trim())
                .toList(),
            onChanged: (value) {
              if (value == null) return;

              final esnaSelected = widget.esnaList.firstWhere(
                    (e) => e.shortName.trim() == value.trim(),
                orElse: () => throw Exception('ES&A not found'),
              );

              setState(() {
                selectedEsnaName = esnaSelected.shortName;
                selectedEsnaEmpId = esnaSelected.empId;
              });
            },
            required: true,
          ),

          const SizedBox(height: 16),

          /// View Document Dropdown
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
                selectedDocumentName = doc;
              });
            },
            required: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottom: ActionButtonPair(
        primaryText: 'Proceed',

        primaryMessage: selectedEsnaName == null
            ? null
            : '$selectedEsnaName has been assigned to ${widget.request.requestId} request',

        onPrimaryAction: selectedEsnaName == null
            ? null // 👈 THIS prevents auto pop
            : _handleApprove,

        onSecondaryAction: null,
      ),
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

  Future<void> _handleApprove() async {
    final requestId = widget.request.requestId;
    final esnaEmpId = selectedEsnaEmpId;

    if (requestId == null || esnaEmpId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing request or ES&A details')),
      );
      return;
    }

    try {
      final response = await _client.assignOrUpdateEsnaSpoc(
        requestId: requestId,
        assignedEsnaEmpId: esnaEmpId,
      );

      // Navigator.pop(context, response); // success close
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

  bool _validateBeforeSubmit() {
    if (selectedEsnaName == null) {
      _showSnackBar(
        context: context,
        message: "Select ES&A",
        isSuccess: false,
      );
      return false;
    }

    return true; // ✅ all inputs valid
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
}
