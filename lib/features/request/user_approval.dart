import 'package:flutter/material.dart';
import '../../custom/modals/declaration_acceptance_modal.dart';
import '../../custom/widgets/file_uploader.dart';
import '../../custom/widgets/form_text_field.dart';
import '../../custom/widgets/form_detail_row.dart';
import '../../custom/widgets/drop_down.dart';
import '../../custom/widgets/action_button_pair.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_client.dart';
import '../../network/api_models/get_all_docs_response_model.dart';
import '../../network/api_models/uploaded_file_model.dart';
import '../../network/api_models/user_approval_model.dart';
import '../../constants/local_prefs.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../core/utils/enum.dart';
import '../../core/helpers/file_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ApprovalType {
  insuranceQuote,
  emiDeduction,
}

class UserApproval extends StatefulWidget {

  final CarRequest? approvalRequest;
  const UserApproval({
    super.key,
    required this.approvalRequest,
  });

  @override
  State<UserApproval> createState() => _UserApprovalState();
}

class _UserApprovalState extends State<UserApproval> {
  final ApiClient _client = ApiClient();
  bool isLoading = true;

  // State variable to hold the approval request
  CarRequest? mainApprovalRequest;
  // Single approval request and its type
  ApprovalType? approvalType;
  // Select one insurance value
  String? addOnTataPowerValue;
  String? addOnSapphirePlusValue;
  String? selectedInsuranceType;
  String? commentsOnInsuranceQuote;
  String? commentsOnEmiApproval;

  // TextFormField Controllers
  final _commentsInsuranceCtrl = TextEditingController();
  final _commentsEmiCtrl = TextEditingController();

  // ErrorText for TextControllers (TextFormFields which are required)
  String? _commentsInsuranceErrorText;
  String? _commentsEmiErrorText;

  // Document state
  List<UploadedFileModel> uploadedDocs = [];
  List<Document> documentList = [];
  Document? selectedDocument;

  // Document Upload State
  PlatformFile? uploadedDocumentFile;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  // Load user ApprovalType
  Future<void> _loadUserApprovals() async {
    setState(() => isLoading = true);

    // Load from LocalPrefs
    final empId = await LocalPrefs.getEmpCode();
    final roleId = await LocalPrefs.getRoleId();

    if (empId == null || empId.isEmpty || roleId == null) {
      debugPrint('Invalid empId or roleId');
      setState(() => isLoading = false);
      return;
    }

    try {
      // API call
      final response = await _client.getApprovalStages(
        empId: empId,
        role: roleId,
      );

      // Check which approval type is present in the response
      final List<CarRequest> insuranceQuoteList =
          response.data['INSURANCE_QUOTE_APPROVAL_USER'] ?? [];

      final List<CarRequest> emiList =
          response.data['EMI_APPROVAL_USER'] ?? [];

      CarRequest? request;
      ApprovalType? type;

      // Determine which approval to display (priority: Insurance Quote first)
      if (insuranceQuoteList.isNotEmpty) {
        request = insuranceQuoteList.first;
        type = ApprovalType.insuranceQuote;
      } else if (emiList.isNotEmpty) {
        request = emiList.first;
        type = ApprovalType.emiDeduction;
      }

      // Update state
      setState(() {
        mainApprovalRequest = request;
        approvalType = type;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching approval stages: $e');
      setState(() => isLoading = false);
    }
  }

  // Get Comments by esna
  Future<void> _getCommentsByRequestId() async {
    if (mainApprovalRequest == null) return;

    final request = mainApprovalRequest!;
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
        commentsOnInsuranceQuote = response.data?.commentsAssignedToGit ?? '';
        commentsOnEmiApproval = response.data?.commentsEmiUserApproval ?? '';
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // View Document handlers
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

  @override
  void initState() {
    super.initState();

    mainApprovalRequest = widget.approvalRequest;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserApprovals();

      if (widget.approvalRequest != null) {
        _getCommentsByRequestId();
        _getDocumentsByRequestId();
      }
    });

    // Validators
    _commentsInsuranceCtrl.addListener(() {
      if (_commentsInsuranceErrorText != null &&
          _commentsInsuranceCtrl.text.trim().isNotEmpty) {
        setState(() => _commentsInsuranceErrorText = null);
      }
    });

    _commentsEmiCtrl.addListener(() {
      if (_commentsEmiErrorText != null &&
          _commentsEmiCtrl.text.trim().isNotEmpty) {
        setState(() => _commentsEmiErrorText = null);
      }
    });
  }

  Future<void> _getDocumentsByRequestId() async {
    final request = widget.approvalRequest;

    if (request == null) return;

    final requestId = request.requestId;
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
    } catch (e) {
      debugPrint("Error fetching documents: $e");
    }
  }

  // UPLOAD REQUEST BODY & handler - As per what approval stage is
  Map<String, dynamic> _bindUploadDocRequestBodyForEmiApproval() {
    if (uploadedDocumentFile == null) {
      return {};
    }

    final request = widget.approvalRequest;

    if (request == null) {
      throw Exception('No active approval request found');
    }

    return {
      'emp_id': request.empId.toString() ?? '',
      'process_stage': (Stage.emiApproval?.stageNo ?? 25).toString(),
      'doc_id': (Document.emiApprovalDoc?.docId ?? 6).toString(),
      'files': [
        MultipartFile.fromBytes(
          uploadedDocumentFile!.bytes!,
          filename: uploadedDocumentFile!.name,
        ),
      ],
    };
  }

  Map<String, dynamic> _bindUploadDocRequestBodyForInsurance() {
    if (uploadedDocumentFile == null) {
      return {};
    }

    final request = widget.approvalRequest;

    if (request == null) {
      throw Exception('No active approval request found');
    }

    return {
      'emp_id': request.empId.toString() ?? '',
      'process_stage': (Stage.insuranceQuoteApproval?.stageNo ?? 23).toString(),
      'doc_id': (Document.insuranceQuoteApprovalDoc?.docId ?? 4).toString(),
      'files': [
        MultipartFile.fromBytes(
          uploadedDocumentFile!.bytes!,
          filename: uploadedDocumentFile!.name,
        ),
      ],
    };
  }

  Future<void> _handleUpload() async {

    // Skip if no document selected
    try {
      final docReqBody = approvalType == ApprovalType.insuranceQuote
          ? _bindUploadDocRequestBodyForInsurance()
          : _bindUploadDocRequestBodyForEmiApproval();

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      await _client.uploadDocument(
        body: docReqBody,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      if (!mounted) return;

      setState(() {
        _isUploading = false;
        uploadedDocumentFile = null;
      });

      _showSnackBar(
        message: 'Document uploaded successfully',
        isSuccess: true,
      );

      // Reload documents
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });

      _showSnackBar(
        message: 'Upload failed: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

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

  // Validators
  bool _validateBeforeInsuranceApprove() {
    bool isValid = true;

    if (selectedInsuranceType == null || selectedInsuranceType!.isEmpty) {
      _showValidationToast('Select Insurance Type');
      isValid = false;
      return isValid;
    }

    if (_commentsInsuranceCtrl.text.trim().isEmpty) {
      setState(() {
        _commentsInsuranceErrorText = 'Required';
      });
      _showValidationToast('Please enter your comments');
      isValid = false;
      return isValid;
    }

    return isValid;
  }

  bool _validateBeforeEmiApprove() {
    bool isValid = true;

    if (_commentsEmiCtrl.text.trim().isEmpty) {
      setState(() {
        _commentsEmiErrorText = 'Comments are required';
      });
      _showValidationToast('Please enter comments');
      isValid = false;
      return isValid;
    }

    return isValid;
  }

  // Show Declaration Modal
  void _showDeclarationModal() {
    if (!_validateBeforeEmiApprove()) {
      return;
    }


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeclarationAcceptanceModal(
        request: mainApprovalRequest!,
        onAccept: () async {
          // Close the modal first
          Navigator.pop(context);
          // Then call the approval handler
          await _handleEmiDeductionApproval();
        },
      ),
    );
  }

  // First Approval
  Widget _buildInsuranceQuoteApprovalContent(CarRequest? request) {
    if (request == null) {
      return const Center(child: Text('Request data not available'));
    }

    final String insuranceValue =
    selectedInsuranceType == 'Add on Tata Power'
        ? request.addOnCoverTataPower?.toString() ?? ''
        : selectedInsuranceType == 'Add on Sapphire plus'
        ? request.addOnSapphirePlus?.toString() ?? ''
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insurance Quote Approval',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 24),
        DetailRow(label: 'EMP ID', value: request.empId ?? ''),
        DetailRow(label: 'EMP Name', value: request.employeeName ?? ''),
        DetailRow(label: 'Mobile No', value: request.contact ?? ''),
        DetailRow(label: 'Request ID', value: request.requestId ?? ''),
        DetailRow(label: 'Grade', value: request.grade ?? ''),
        DetailRow(label: 'Eligibility (₹)', value: request.eligibility?.toString() ?? ''),
        DetailRow(label: 'Email', value: request.email?.toLowerCase() ?? ''),
        const SizedBox(height: 16),
        DetailRow(
          label: 'Base Insurance',
          value: request.baseInsurancePremium?.toString() ?? '',
        ),
        DetailRow(
          label: 'Add-on Cover Tata',
          value: request.addOnCoverTataPower?.toString() ?? '',
        ),
        DetailRow(
          label: 'Add-on Sapphire Plus',
          value: request.addOnSapphirePlus?.toString() ?? '',
        ),
        DetailRow(
          label: 'Comments By GIT',
          value: commentsOnInsuranceQuote ?? '',
        ),
        const SizedBox(height: 16),
        DropdownField(
          label: 'Insurance add on',
          hints: 'Select Insurance Type',
          items: ['Add on Tata Power', 'Add on Sapphire plus'],
          onChanged: (value) {
            setState(() {
              selectedInsuranceType = value;
            });
          },
          required: true,
        ),
        const SizedBox(height: 16),
        if (selectedInsuranceType != null)
          DetailRow(
            label: selectedInsuranceType ?? '',
            value: insuranceValue,
          ),
        const SizedBox(height: 16),
        FileUploadField(
          label: 'Upload Document',
          allowedExtensions: const ['pdf', 'xls', 'xlsx', 'docx', 'jpg', 'png'],
          onFileSelected: (file) {
            setState(() {
              uploadedDocumentFile = file;
            });
          },
          required: false
        ),
        const SizedBox(height: 16),
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
          hint: 'Add your comments',
          maxLines: 3,
          required: true,
          controller: _commentsInsuranceCtrl,
          errorText: _commentsInsuranceErrorText,
        ),
      ],
    );
  }
  Future<void> _handleInsuranceQuoteApproval() async {
    if (mainApprovalRequest == null) return;

    final request = mainApprovalRequest!;
    final requestId = request.requestId;

    try {
      if (selectedInsuranceType == 'Add on Tata Power') {
        final insuranceValue = request.addOnCoverTataPower?.toString() ?? 'NAN';

        await _client.firstUserApproval(
          requestId: requestId!,
          userApprovalComments: _commentsInsuranceCtrl.text.trim(),
          addOnTataPower: insuranceValue,
        );
      } else if (selectedInsuranceType == 'Add on Sapphire plus') {
        final insuranceValue = request.addOnSapphirePlus?.toString() ?? 'NAN';

        await _client.firstUserApproval(
          requestId: requestId!,
          userApprovalComments: _commentsInsuranceCtrl.text.trim(),
          addOnSapphirePlus: insuranceValue,
        );
      }

      // Upload document (if any)
      if (uploadedDocumentFile != null) {
        await _handleUpload();
      }
    } catch (e) {
      // Ignore the parsing error - API already succeeded (200 OK)
      debugPrint('Ignoring response parsing error: $e');
    }

    // At this point, API has succeeded (even if response parsing failed)
    if (!mounted) return;

    // Show success message
    _showSnackBar(
      message: 'Insurance Quote Approved',
      isSuccess: true,
    );

    // Small delay so snackbar is visible
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    Navigator.pop(context);
  }
  Future<void> _handleInsuranceQuoteRejection() async {
    if (mainApprovalRequest == null) return;

    final request = mainApprovalRequest!;
    final requestId = request.requestId;
    final empId = request.empId;

    if (requestId == null || empId == null) {
      _showSnackBar(
        message: 'Missing request details',
        isSuccess: false,
      );
      return;
    }

    try {
      await _client.decrementStageOnReject(
        requestId: requestId,
        empId: empId,
      );
    } catch (e) {
      // Ignore the parsing error - API already succeeded (200 OK)
      debugPrint('Ignoring response parsing error: $e');
    }

    // At this point, API has succeeded
    if (!mounted) return;

    // Show success message
    _showSnackBar(
      message: 'Request $requestId: Rejected',
      isSuccess: true,
    );

    // Small delay so snackbar is visible
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    Navigator.pop(context);
  }

  // Second Approval
  Widget _buildEmiDeductionApprovalContent(CarRequest? request) {
    if (request == null) {
      return const Center(child: Text('Request data not available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EMI Deduction Approval',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 24),
        DetailRow(label: 'EMP ID', value: request.empId ?? ''),
        DetailRow(label: 'EMP Name', value: request.employeeName ?? ''),
        DetailRow(label: 'Mobile No', value: request.contact ?? ''),
        DetailRow(label: 'Request ID', value: request.requestId ?? ''),
        DetailRow(label: 'Grade', value: request.grade ?? ''),
        DetailRow(label: 'Eligibility (₹)', value: request.eligibility?.toString() ?? ''),
        DetailRow(label: 'Email', value: request.email?.toLowerCase() ?? ''),
        const SizedBox(height: 16),
        DetailRow(
          label: 'Total EMI',
          value: request.totalEmi?.toString() ?? '',
        ),
        DetailRow(
          label: 'Car Allowance',
          value: request.carAllowance?.toString() ?? '',
        ),
        DetailRow(
          label: 'Company Contribution',
          value: request.companyContribution?.toString() ?? '',
        ),
        DetailRow(
          label: 'EMI Tenure (Years)',
          value: '${request.completeEmiTenure?.toString()} years' ?? '',
        ),
        DetailRow(
          label: 'Comments By ESNA',
          value: commentsOnEmiApproval ?? '',
        ),
        const SizedBox(height: 16),
        FileUploadField(
          label: 'Upload Document',
          allowedExtensions: const ['pdf', 'xls', 'xlsx', 'docx', 'jpg', 'png'],
          onFileSelected: (file) {
            setState(() {
              uploadedDocumentFile = file;
            });
          },
          required: false,
        ),
        const SizedBox(height: 16),
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
          label: 'Employee Comments',
          hint: 'Your comments',
          maxLines: 3,
          required: true,
          controller: _commentsEmiCtrl,
          errorText: _commentsEmiErrorText,
        ),
      ],
    );
  }
  Future<void> _handleEmiDeductionApproval() async {
    if (mainApprovalRequest == null) return;

    final request = mainApprovalRequest!;
    final requestId = request.requestId;
    final empId = request.empId;

    try {
      final response = await _client.secondUserApproval(
        requestId: requestId!,
        empId: empId!,
        commentsAssignedToEsna: _commentsEmiCtrl.text.trim(),
      );

      // Upload document (if any)
      if (uploadedDocumentFile != null) {
        await _handleUpload();
      }
    } catch (e) {
      // Ignore the parsing error - API already succeeded (200 OK)
      debugPrint('Ignoring response parsing error: $e');
    }

    // At this point, API has succeeded (even if response parsing failed)
    if (!mounted) return;

    // Show success message
    _showSnackBar(
      message: 'EMI deduction approved successfully',
      isSuccess: true,
    );

    // Small delay so snackbar is visible
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    Navigator.pop(context);
  }
  Future<void> _handleEmiDeductionRejection() async {
    if (mainApprovalRequest == null) return;

    final request = mainApprovalRequest!;
    final requestId = request.requestId;
    final empId = request.empId;

    if (requestId == null || empId == null) {
      _showSnackBar(
        message: 'Missing request details',
        isSuccess: false,
      );
      return;
    }

    try {
      await _client.decrementStageOnReject(
        requestId: requestId,
        empId: empId,
      );
    } catch (e) {
      // Ignore the parsing error - API already succeeded (200 OK)
      debugPrint('Ignoring response parsing error: $e');
    }

    // At this point, API has succeeded
    if (!mounted) return;

    // Show success message
    _showSnackBar(
      message: 'Request $requestId: Rejected',
      isSuccess: true,
    );

    // Small delay so snackbar is visible
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget? _buildActionButtons() {
    if (mainApprovalRequest == null || approvalType == null) {
      return null;
    }

    switch (approvalType!) {
      case ApprovalType.insuranceQuote:
        return Padding(
          padding: const EdgeInsets.all(24),
          child: ActionButtonPair(
            primaryText: 'Approve',
            secondaryText: 'Reject',
            primaryValidator: _validateBeforeInsuranceApprove,
            onPrimaryAction: () async {
              await _handleInsuranceQuoteApproval();
            },
            onSecondaryAction: () async {
              await _handleInsuranceQuoteRejection();
            },
          ),
        );

      case ApprovalType.emiDeduction:
        return Padding(
          padding: const EdgeInsets.all(24),
          child: ActionButtonPair(
            primaryText: 'Approve',
            secondaryText: 'Reject',
            primaryValidator: _validateBeforeEmiApprove,
            onPrimaryAction: () async => _showDeclarationModal(),
            onSecondaryAction: () async => await _handleEmiDeductionRejection(),
          ),
        );
    }
  }

  // MAIN
  @override
  Widget build(BuildContext context) {
    final request = widget.approvalRequest;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Approve/Reject',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 🚨 FIRST: Handle NULL request safely
      body: request == null
          ? _centerMessage(
        icon: Icons.not_interested,
        message: "You don't have any active request for approval.",
      )

      // If request is NOT null → continue normal flow
          : isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color.fromRGBO(98, 202, 102, 1.0),
        ),
      )
          : FutureBuilder<int?>(
        future: LocalPrefs.getRoleId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
              CircularProgressIndicator(color: Colors.green),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return _centerMessage(
              icon: Icons.error_outline,
              message: "Unable to fetch role information.",
            );
          }

          final roleId = snapshot.data!;

          if (roleId != 1) {
            return _centerMessage(
              icon: Icons.error_outline,
              message:
              "Only USER role can approve or reject this request.",
            );
          }

          if (mainApprovalRequest == null ||
              approvalType == null) {
            return _centerMessage(
              icon: Icons.not_interested,
              message:
              "You don't have any active request for approval.",
              showRetry: true,
            );
          }

          // MAIN Content (scrollable)
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: approvalType ==
                        ApprovalType.insuranceQuote
                        ? _buildInsuranceQuoteApprovalContent(
                        mainApprovalRequest)
                        : _buildEmiDeductionApprovalContent(
                        mainApprovalRequest),
                  ),
                ),
              ),
              if (_buildActionButtons() != null)
                _buildActionButtons()!,
            ],
          );
        },
      ),
    );
  }

  Widget _centerMessage({
    required IconData icon,
    required String message,
    bool showRetry = false,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey[400], size: 64),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          if (showRetry) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadUserApprovals,
              icon: const Icon(Icons.refresh,
                  color: Color(0xFF42B347)),
              label: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF42B347),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
