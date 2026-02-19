import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/action_button_pair.dart';
import '../widgets/form_detail_row.dart';
import '../widgets/drop_down.dart';
import './base_modal.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_models/list_of_esna_model.dart';
import '../../network/api_client.dart';
import '../../core/utils/enum.dart';
import '../../network/api_models/get_all_docs_response_model.dart';
import '../../network/api_models/uploaded_file_model.dart';
import '../../core/helpers/file_downloader.dart';

class AssignEsnaCardModal extends StatefulWidget {
  final CarRequest request;
  final List<GetListOfEsnaModel> esnaList;

  const AssignEsnaCardModal({
    super.key,
    required this.request,
    required this.esnaList,
  });

  @override
  State<AssignEsnaCardModal> createState() => _AssignEsnaCardModalState();
}

class _AssignEsnaCardModalState extends State<AssignEsnaCardModal> {
  final ApiClient _client = ApiClient();

  String? selectedEsnaName;
  String? selectedEsnaEmpId;

  List<UploadedFileModel> uploadedDocs = [];
  List<Document> documentList = [];
  Document? selectedDocument;

  // Inline error state for the ES&A dropdown
  bool _esnaNotSelectedError = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getDocumentsByRequestId();
    });
  }

  // ==================== VALIDATION ====================

  bool _validateBeforeSubmit() {
    if (selectedEsnaName == null) {
      setState(() => _esnaNotSelectedError = true);
      return false;
    }
    return true;
  }

  // ==================== SUBMISSION HANDLERS ====================

  /// Pure API worker — no Navigator.pop, no snackbars.
  Future<void> _handleApprove() async {
    final requestId = widget.request.requestId;
    final esnaEmpId = selectedEsnaEmpId;

    if (requestId == null || esnaEmpId == null) return;

    await _client.assignOrUpdateEsnaSpoc(
      requestId: requestId,
      assignedEsnaEmpId: esnaEmpId,
    );
  }

  // ==================== DATA FETCHING ====================

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
      title: widget.request.requestId ?? '',
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

          // ES&A Dropdown
          DropdownField(
            label: 'Assign ES&A to the Request',
            hints: 'Select ES&A',
            items: widget.esnaList.map((e) => e.shortName.trim()).toList(),
            onChanged: (value) {
              if (value == null) return;

              final esnaSelected = widget.esnaList.firstWhere(
                    (e) => e.shortName.trim() == value.trim(),
                orElse: () => throw Exception('ES&A not found'),
              );

              setState(() {
                selectedEsnaName = esnaSelected.shortName;
                selectedEsnaEmpId = esnaSelected.empId;
                _esnaNotSelectedError = false; // clear error on selection
              });
            },
            required: true,
          ),

          // Inline error under ES&A dropdown
          if (_esnaNotSelectedError)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                'Required',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
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
        primaryText: 'Proceed',
        primaryValidator: () {
          return _validateBeforeSubmit();
        },
        onPrimaryAction: () async {
          await _handleApprove();
          if (!mounted) return;
          _showSnackBar(
            message:
            '$selectedEsnaName has been assigned to ${widget.request.requestId} request',
            isSuccess: true,
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}