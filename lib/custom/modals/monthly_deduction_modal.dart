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

    // Validate all required Excel fields are extracted
    if (_totalEmi == null ||
        _carAllowance == null ||
        _companyContribution == null ||
        _emiTenure == null ||
        _monthlyEmi == null) {
      _showSnackBar(
        context: context,
        message: 'Excel data not properly extracted. Please check the file format.',
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
        message: 'Template downloaded successfully',
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

  /// Parses Excel file and extracts data from specific cells
  Future<void> _handleExcelUpload(PlatformFile? file) async {
    if (file == null || file.bytes == null) {
      _showSnackBar(
        context: context,
        message: 'Invalid file selected',
        isSuccess: false,
      );
      return;
    }

    try {
      // Parse Excel file
      final excel = Excel.decodeBytes(file.bytes!);

      // Get the first sheet (or you can specify sheet name)
      if (excel.tables.isEmpty) {
        throw Exception('Excel file is empty');
      }

      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName];

      if (sheet == null) {
        throw Exception('Could not read Excel sheet');
      }

      // Extract data from specific cells based on Angular code
      // G14 = Total EMI (Rs)
      final totalEmiCell = sheet.cell(CellIndex.indexByString('G14'));
      // G15 = Car Allowance (Rs)
      final carAllowanceCell = sheet.cell(CellIndex.indexByString('G15'));
      // G16 = Company Contribution (Rs)
      final companyContributionCell = sheet.cell(CellIndex.indexByString('G16'));
      // B3 = EMI Tenure (In Yrs)
      final emiTenureCell = sheet.cell(CellIndex.indexByString('B3'));
      // G17 = Monthly EMI (Rs)
      final monthlyEmiCell = sheet.cell(CellIndex.indexByString('G17'));

      // Parse and validate extracted values
      final totalEmiValue = _parseNumericValue(totalEmiCell.value);
      final carAllowanceValue = _parseNumericValue(carAllowanceCell.value);
      final companyContributionValue = _parseNumericValue(companyContributionCell.value);
      final emiTenureValue = _parseNumericValue(emiTenureCell.value);
      final monthlyEmiValue = _parseNumericValue(monthlyEmiCell.value);

      // Validate that all required fields have values
      if (totalEmiValue == null ||
          carAllowanceValue == null ||
          companyContributionValue == null ||
          emiTenureValue == null ||
          monthlyEmiValue == null) {
        throw Exception('One or more required cells are empty or invalid');
      }

      // Update state with extracted data
      setState(() {
        uploadedExcelFile = file;
        _excelUploaded = true;
        _totalEmi = totalEmiValue;
        _carAllowance = carAllowanceValue;
        _companyContribution = companyContributionValue;
        _emiTenure = emiTenureValue;
        _monthlyEmi = monthlyEmiValue;
      });

      if (!mounted) return;

      _showSnackBar(
        context: context,
        message: 'Excel data extracted successfully',
        isSuccess: true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _excelUploaded = false;
        uploadedExcelFile = null;
        _totalEmi = null;
        _carAllowance = null;
        _companyContribution = null;
        _emiTenure = null;
        _monthlyEmi = null;
      });

      _showSnackBar(
        context: context,
        message: 'Error parsing Excel file: $e',
        isSuccess: false,
      );
    }
  }

  /// Safely parses numeric values from Excel cells
  double? _parseNumericValue(Data? cellValue) {
    if (cellValue == null || cellValue.value == null) return null;

    final value = cellValue.value;

    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value);
    }

    return null;
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
  Future<void> _handleApprove() async {
    // Validate before proceeding
    if (!_validateBeforeApprove()) return;

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
      // STEP 1: Upload EMI calculation Excel document
      await _handleUpload();

      // STEP 2: Submit for EMI approval with extracted data
      final response = await _client.submitByEsnaEmi(
        requestId: requestId,
        empId: empId,
        commentsAssignedToEsna: _commentsCtrl.text.trim(),
        // Optionally send extracted data to backend
        // totalEmi: _totalEmi,
        // carAllowance: _carAllowance,
        // companyContribution: _companyContribution,
        // emiTenure: _emiTenure?.toInt(),
        // monthlyEmi: _monthlyEmi,
      );

      if (!mounted) return;

      // Success feedback
      _showSnackBar(
        context: context,
        message: 'EMI calculation submitted successfully',
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

  /// Formats currency values for display
  String _formatCurrency(double? value) {
    if (value == null) return 'N/A';
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  /// Formats tenure values for display
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

          // Extracted Data Section - Based on Angular fields
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

            // G14 - Total EMI (Rs)
            DetailRow(
              label: 'Total EMI (Rs)',
              value: _formatCurrency(_totalEmi),
            ),

            // G15 - Car Allowance (Rs)
            DetailRow(
              label: 'Car Allowance (Rs)',
              value: _formatCurrency(_carAllowance),
            ),

            // G16 - Company Contribution (Rs)
            DetailRow(
              label: 'Company Contribution (Rs)',
              value: _formatCurrency(_companyContribution),
            ),

            // B3 - EMI Tenure (In Yrs)
            DetailRow(
              label: 'EMI Tenure',
              value: _formatTenure(_emiTenure),
            ),

            // G17 - Monthly EMI (Rs)
            DetailRow(
              label: 'Monthly EMI (Rs)',
              value: _formatCurrency(_monthlyEmi),
            ),

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
        primaryValidator: _validateBeforeApprove,
        onPrimaryAction: _handleApprove,
        onSecondaryAction: _handleReject,
      ),
    );
  }
}