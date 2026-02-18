import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:excel/excel.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_client.dart';
import '../../core/utils/enum.dart';
import '../widgets/form_detail_row.dart';
import '../widgets/excel_file_upload_field.dart';
import '../widgets/form_text_field.dart';
import '../widgets/action_button_pair.dart';
import './base_modal.dart';

class MonthlyDeductionModal extends StatefulWidget {
  final CarRequest request;

  const MonthlyDeductionModal({
    super.key,
    required this.request,
  });

  @override
  State<MonthlyDeductionModal> createState() => _MonthlyDeductionModalState();
}

class _MonthlyDeductionModalState extends State<MonthlyDeductionModal> {
  final ApiClient _client = ApiClient();

  // Form Controllers
  final _commentsCtrl = TextEditingController();

  // Excel Data State - Based on Angular cell references
  // G14 = Total EMI
  // G15 = Car Allowance
  // G16 = Company Contribution
  // B3 = EMI Tenure (Years)
  // G17 = Monthly EMI
  double? _totalEmi;           // G14
  double? _carAllowance;        // G15
  double? _companyContribution; // G16
  double? _emiTenure;           // B3
  double? _monthlyEmi;          // G17
  bool _excelUploaded = false;

  // Document Upload State
  PlatformFile? uploadedExcelFile;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    // 1️⃣ Fetch comments after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCommentsByRequestId();
    });

    // 2️⃣ Listen to comments controller to reset error border on typing
    _commentsCtrl.addListener(() {
      if (_commentsErrorText != null && _commentsCtrl.text.trim().isNotEmpty) {
        setState(() {
          _commentsErrorText = null;
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

  Map<String, dynamic> _bindUploadDocRequestBody() {
    if (uploadedExcelFile == null) {
      throw Exception('No file selected');
    }

    return {
      'emp_id': widget.request.empId.toString(),
      'process_stage': (Stage.emiCalculation?.stageNo ?? 24).toString(),
      'doc_id': (Document.emiCalculationDoc?.docId ?? 5).toString(),
      'files': [
        MultipartFile.fromBytes(
          uploadedExcelFile!.bytes!,
          filename: uploadedExcelFile!.name,
        ),
      ],
    };
  }

  // ==================== VALIDATION ====================

  String? _commentsErrorText;
  bool _validateBeforeApprove() {
    if (_commentsCtrl.text.trim().isEmpty) {
      setState(() {
        _commentsErrorText = 'Required';
      });
      return false;
    }
    return true;
  }

  // ==================== EXCEL TEMPLATE DOWNLOAD ====================

  /// Downloads the EMI Calculator Excel template.
  /// On iOS: writes to a temp file and triggers the share sheet so the user
  /// can save it to Files, Mail, etc. — this is the correct iOS pattern.
  /// On Android: writes directly to the Downloads folder.
  Future<void> _downloadExcelTemplate() async {
    try {
      // Android needs storage permission
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) return;
        }
      }

      // Load the Excel file from assets
      final ByteData data =
      await rootBundle.load('assets/docs/EMI_Calculator.xlsx');
      final List<int> bytes = data.buffer.asUint8List();

      if (Platform.isIOS) {
        // ✅ iOS: write to temp dir then share — this surfaces the standard
        //    "Save to Files / AirDrop / Mail…" sheet which is the only way
        //    an iOS app can hand a file off to the user visibly.
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/EMI_Calculator.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'EMI Calculator Template',
        );
      } else {
        // Android: write straight to Downloads
        Directory directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = (await getExternalStorageDirectory())!;
        }
        final filePath = '${directory.path}/EMI_Calculator.xlsx';
        await File(filePath).writeAsBytes(bytes);
      }
    } catch (_) {
      // Fail silently — the share sheet cancel is not an error
    }
  }

  // ==================== EXCEL PROCESSING ====================

  /// Parses Excel file and extracts data from specific cells.
  /// Falls back to 100 for any cell that is missing or unparseable.
  Future<void> _handleExcelUpload(PlatformFile? file) async {
    if (file == null || file.bytes == null) return;

    try {
      final excel = Excel.decodeBytes(file.bytes!);

      if (excel.tables.isEmpty) throw Exception('Excel file is empty');

      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName];

      if (sheet == null) throw Exception('Could not read Excel sheet');

      // Extract and parse — fall back to 100.0 if a cell is empty/invalid
      final totalEmiValue =
          _parseNumericValue(sheet.cell(CellIndex.indexByString('G14')).value) ??
              100.0;
      final carAllowanceValue =
          _parseNumericValue(sheet.cell(CellIndex.indexByString('G15')).value) ??
              100.0;
      final companyContributionValue =
          _parseNumericValue(sheet.cell(CellIndex.indexByString('G16')).value) ??
              100.0;
      final emiTenureValue =
          _parseNumericValue(sheet.cell(CellIndex.indexByString('B3')).value) ??
              100.0;
      final monthlyEmiValue =
          _parseNumericValue(sheet.cell(CellIndex.indexByString('G17')).value) ??
              100.0;

      setState(() {
        uploadedExcelFile = file;
        _excelUploaded = true;
        _totalEmi = totalEmiValue;
        _carAllowance = carAllowanceValue;
        _companyContribution = companyContributionValue;
        _emiTenure = emiTenureValue;
        _monthlyEmi = monthlyEmiValue;
      });
    } catch (_) {
      // Reset state silently on parse failure
      setState(() {
        _excelUploaded = false;
        uploadedExcelFile = null;
        _totalEmi = null;
        _carAllowance = null;
        _companyContribution = null;
        _emiTenure = null;
        _monthlyEmi = null;
      });
    }
  }

  /// Safely parses numeric values from Excel cells
  double? _parseNumericValue(dynamic cellValue) {
    if (cellValue == null) return null;

    if (cellValue is num) return cellValue.toDouble();
    if (cellValue is String) return double.tryParse(cellValue);

    return null;
  }

  // ==================== SUBMISSION HANDLERS ====================

  /// Handles document upload with progress tracking.
  /// Silently skips if no file is selected — upload is optional.
  Future<void> _handleUpload() async {
    if (uploadedExcelFile == null) return;

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

      rethrow;
    }
  }

  /// Pure API worker — no Navigator.pop, no snackbars.
  /// Falls back to 100 for any Excel value that was not extracted.
  Future<void> _handleApprove() async {
    final requestId = widget.request.requestId;
    final empId = widget.request.empId;

    if (requestId == null || empId == null) return;

    // STEP 1: Upload EMI calculation Excel document (optional)
    await _handleUpload();

    // STEP 2: Submit for EMI approval with extracted data (100 fallback each)
    await _client.submitByEsnaEmi(
      requestId: requestId,
      empId: empId,
      commentsAssignedToEsna: _commentsCtrl.text.trim(),
      totalEmi: (_totalEmi ?? 100).toString(),
      carAllowance: (_carAllowance ?? 100).toString(),
      companyContribution: (_companyContribution ?? 100).toString(),
      completeEmiTenure: (_emiTenure ?? 100).toInt().toString(),
      emiAmount: (_monthlyEmi ?? 100).toString(),
    );
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

  // ==================== DATA FETCHING ====================

  Future<void> _getCommentsByRequestId() async {
    final requestId = widget.request.requestId;
    if (requestId == null) return;

    try {
      final response = await _client.getCommentsByRequestId(
        requestId: requestId,
      );

      if (!mounted) return;

      // If you need to display previous comments, store them in state here
      // setState(() { _previousComments = response.data?.someField ?? 'NULL'; });
    } catch (_) {}
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
          duration: const Duration(seconds: 3),
        ),
      );
  }

  String _formatCurrency(double? value) {
    if (value == null) return 'N/A';
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  String _formatTenure(double? value) {
    if (value == null) return 'N/A';
    return '${value.toInt()} years';
  }

  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      request: widget.request,
      title: 'Monthly Deduction',
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
          const SizedBox(height: 24),

          // Step 1: Download Template
          const Text(
            "1. Download and fill the EMI Calculator excel",
            style: TextStyle(
              color: Color.fromRGBO(108, 108, 108, 1.0),
              fontFamily: 'Inter',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _downloadExcelTemplate,
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Download Excel Template'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF585858),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Step 2: Upload Filled Excel
          ExcelFileUploadField(
            label: '2. Upload Excel',
            onFileSelected: _handleExcelUpload,
          ),
          const SizedBox(height: 24),

          // Extracted Data Section
          if (_excelUploaded) ...[
            const Text(
              'Extracted Data',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            DetailRow(label: 'Total EMI (Rs)', value: _formatCurrency(_totalEmi)),
            DetailRow(label: 'Car Allowance (Rs)', value: _formatCurrency(_carAllowance)),
            DetailRow(label: 'Company Contribution (Rs)', value: _formatCurrency(_companyContribution)),
            DetailRow(label: 'EMI Tenure', value: _formatTenure(_emiTenure)),
            DetailRow(label: 'Monthly EMI (Rs)', value: _formatCurrency(_monthlyEmi)),
            const SizedBox(height: 24),
          ],

          // ES&A Comments
          FormTextField(
            label: 'ES&A Comments',
            hint: 'Enter Your Comments',
            maxLines: 3,
            controller: _commentsCtrl,
            required: true,
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