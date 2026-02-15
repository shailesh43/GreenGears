import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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

  // Excel Data State
  String? _total;
  String? _carAllowance;
  String? _companyContribution;
  String? _emiTenure;
  String? _monthlyEmi;
  bool _excelUploaded = false;

  // Document Upload State
  PlatformFile? uploadedExcelFile;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  @override
  void dispose() {
    _commentsCtrl.dispose();
    super.dispose();
  }

  // ==================== REQUEST BODY BUILDERS ====================

  /// Prepares the document upload payload for EMI calculation Excel
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

  /// Validates all required fields before approval
  bool _validateBeforeApprove() {
    // Excel upload validation
    if (!_excelUploaded || uploadedExcelFile == null) {
      _showSnackBar(
        context: context,
        message: 'Please upload the EMI Calculator Excel file',
        isSuccess: false,
      );
      return false;
    }

    // Comments validation
    if (_commentsCtrl.text.trim().isEmpty) {
      _showSnackBar(
        context: context,
        message: 'Please enter your comments',
        isSuccess: false,
      );
      return false;
    }

    // Validate extracted data
    if (_total == null || _monthlyEmi == null) {
      _showSnackBar(
        context: context,
        message: 'Excel data not properly extracted',
        isSuccess: false,
      );
      return false;
    }

    return true;
  }

  // ==================== EXCEL TEMPLATE DOWNLOAD ====================

  /// Downloads the EMI Calculator Excel template
  Future<void> _downloadExcelTemplate() async {
    try {
      // Request storage permission for Android
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            if (!mounted) return;
            _showSnackBar(
              context: context,
              message: 'Storage permission denied',
              isSuccess: false,
            );
            return;
          }
        }
      }

      // Load the Excel file from assets
      final ByteData data = await rootBundle.load('assets/docs/EMI_Calculator.xlsx');
      final List<int> bytes = data.buffer.asUint8List();

      // Get the Downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not find download directory');
      }

      // Create the file path
      final String filePath = '${directory.path}/EMI_Calculator.xlsx';
      final File file = File(filePath);

      // Write the file
      await file.writeAsBytes(bytes);

      if (!mounted) return;

      // Show success message
      _showSnackBar(
        context: context,
        message: 'Template downloaded to: $filePath',
        isSuccess: true,
      );
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(
        context: context,
        message: 'Error downloading template: $e',
        isSuccess: false,
      );
    }
  }

  // ==================== EXCEL PROCESSING ====================

  /// Handles Excel file upload and data extraction
  Future<void> _handleExcelUpload(PlatformFile? file) async {
    if (file == null) {
      _showError("No file selected.");
      return;
    }

    try {
      if (file.bytes == null) {
        _showError("File data missing. Please re-upload.");
        return;
      }

      final excel = Excel.decodeBytes(file.bytes!);

      if (excel.tables.isEmpty) {
        _showError("Invalid Excel file.");
        return;
      }

      String? total;
      String? carAllowance;
      String? companyContribution;
      String? emiTenure;
      String? monthlyEmi;

      for (var sheet in excel.tables.values) {
        if (sheet == null) continue;

        for (var row in sheet.rows) {
          if (row.isEmpty) continue;

          final firstCell =
              row[0]?.value?.toString().trim().toLowerCase() ?? '';

          if (firstCell.contains('total vehicle cost')) {
            total = _formatCurrency(row[1]?.value);
          }

          if (firstCell.contains('car allowance')) {
            carAllowance = _formatCurrency(row[1]?.value);
          }

          if (firstCell.contains('company contribution')) {
            companyContribution =
                _formatCurrency(row[1]?.value);
          }

          if (firstCell.contains('tenure')) {
            final val = row[1]?.value?.toString();
            if (val != null && val.isNotEmpty) {
              emiTenure = "$val years";
            }
          }

          if (firstCell.contains('monthly emi')) {
            monthlyEmi =
                _formatCurrency(row[1]?.value);
          }
        }
      }

      // ✅ Strict template validation
      if (total == null || monthlyEmi == null) {
        _showError(
            "Invalid EMI template. Please use official format.");
        return;
      }

      setState(() {
        uploadedExcelFile = file;
        _excelUploaded = true;
        _total = total ?? '-';
        _carAllowance = carAllowance ?? '-';
        _companyContribution =
            companyContribution ?? '-';
        _emiTenure = emiTenure ?? '-';
        _monthlyEmi = monthlyEmi ?? '-';
      });

      _showSuccess("Excel parsed successfully.");

    } catch (e) {
      debugPrint("Excel parsing error: $e");
      _showError("Failed to read Excel file.");
    }
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '-';

    double? number;

    if (value is num) {
      number = value.toDouble();
    } else {
      number = double.tryParse(value.toString());
    }

    if (number == null) return '-';

    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );

    return formatter.format(number);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ==================== SUBMISSION HANDLERS ====================

  /// Handles document upload with progress tracking
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

      // Propagate failure to caller
      rethrow;
    }
  }

  /// Handles approval action
  Future<bool> _handleApprove() async {
    // STEP 1: Validate form
    if (!_validateBeforeApprove()) {
      return false;
    }

    final request = widget.request;
    final requestId = request.requestId;
    final empId = request.empId;

    // STEP 2: Basic null safety check
    if (requestId == null || empId == null) {
      _showSnackBar(
        context: context,
        message: 'Missing request or employee details',
        isSuccess: false,
      );
      return false;
    }

    try {
      // STEP 3: Upload Excel file
      await _handleUpload();

      // STEP 4: Submit EMI approval
      await _client.submitByEsnaEmi(
        requestId: requestId,
        empId: empId,
        commentsAssignedToEsna: _commentsCtrl.text.trim(),
      );

      if (!mounted) return false;

      // ✅ Everything succeeded
      return true;
    } catch (e) {
      if (!mounted) return false;

      _showSnackBar(
        context: context,
        message: e.toString(),
        isSuccess: false,
      );

      return false;
    }
  }

  /// Handles rejection action
  Future<void> _handleReject() async {
    final request = widget.request;
    final requestId = request.requestId;
    final empId = request.empId;

    if (requestId == null || empId == null) {
      _showSnackBar(
        context: context,
        message: 'Missing request or employee details',
        isSuccess: false,
      );
      return;
    }

    try {
      final response = await _client.decrementStageOnReject(
        requestId: requestId,
        empId: empId,
      );

      if (!mounted) return;

      _showSnackBar(
        context: context,
        message: 'Request rejected successfully',
        isSuccess: true,
      );

      Navigator.pop(context, response);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // ==================== UI HELPERS ====================

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
        duration: const Duration(seconds: 3),
      ),
    );
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
          const SizedBox(height: 24),

          // Step 1: Download Template
          const Text(
            "1. Download and fill the EMI Calculator excel",
            style: TextStyle(
              color: Color.fromRGBO(108, 108, 108, 1.0),
              fontFamily: 'Inter',
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
            DetailRow(label: 'Total', value: _total ?? 'N/A'),
            DetailRow(label: 'Car Allowance', value: _carAllowance ?? 'N/A'),
            DetailRow(
              label: 'Company Contr.',
              value: _companyContribution ?? 'N/A',
            ),
            DetailRow(
              label: 'EMI Tenure in Years',
              value: _emiTenure ?? 'N/A',
            ),
            DetailRow(label: 'Monthly EMI', value: _monthlyEmi ?? 'N/A'),
            const SizedBox(height: 24),
          ],

          // ES&A Comments
          FormTextField(
            label: 'ES&A Comments',
            hint: 'Enter Your Comments',
            maxLines: 3,
            controller: _commentsCtrl,
            required: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottom: ActionButtonPair(
        primaryText: 'Approve',
        secondaryText: 'Reject',
        primaryMessage: '${widget.request.requestId}: Request Approved',
        secondaryMessage: '${widget.request.requestId}: Request Rejected',
        onPrimaryAction: () async {
          final success = await _handleApprove();

          if (!success) return;

          if (!mounted) return;

          Navigator.pop(context);

          _showSnackBar(
            context: context,
            message: '${widget.request.requestId}: Request Approved',
            isSuccess: true,
          );
        },
        onSecondaryAction: () => _handleReject(),
      ),
    );
  }
}