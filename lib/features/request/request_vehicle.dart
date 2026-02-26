import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../constants/local_prefs.dart';
import 'package:file/file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../core/utils/enum.dart';
import '../../network/api_client.dart';
import '../../custom/widgets/file_uploader.dart';
import '../../custom/modals/quotation_form_modal.dart';
import '../../custom/widgets/form_text_field.dart';
import '../../custom/widgets/form_detail_row.dart';
import '../../custom/widgets/drop_down.dart';

class VehicleRequestPage extends StatefulWidget {
  const VehicleRequestPage({super.key});

  @override
  State<VehicleRequestPage> createState() => _VehicleRequestPageState();
}

class _VehicleRequestPageState extends State<VehicleRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _client = ApiClient();
  final Logger logger = Logger();

  // Form Controllers
  final _manufacturerCtrl = TextEditingController();
  final _vehicleModelCtrl = TextEditingController();
  final _colourCtrl = TextEditingController();
  final _commentsCtrl = TextEditingController();

  // Form State
  String? selectedVehicleType;
  String? quotationAmountModalResult = '0';

  // Document Upload State
  PlatformFile? uploadedQuotationFile;
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  bool isLoading = true;

  // Employee Data
  String? empCode;
  String? empName;
  String? empEmail;
  String? empGrade;
  String? empRole;
  String? empCostCenter;
  String? empMobileNo;
  String? empEligibility;
  String? empCompany;
  String? empDobDate;
  String? empWorkLocation;
  String? empRetirementDate;
  String? empCluster;
  String? empDepartment;
  String? empCompanyCode;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _manufacturerCtrl.dispose();
    _vehicleModelCtrl.dispose();
    _colourCtrl.dispose();
    _commentsCtrl.dispose();
    super.dispose();
  }

  // ==================== INITIALIZATION ====================

  Future<void> _initializeData() async {
    await _loadEmpCodeAndEligibility();
    await _fetchEmployeeProfile();
  }

  Future<void> _loadEmpCodeAndEligibility() async {
    empCode = await LocalPrefs.getEmpCode();
    empEligibility = await LocalPrefs.getEmpEligibility();
    setState(() {
      empCode = empCode;
      empEligibility = empEligibility;
    });
    logger.d("empCode: $empCode");
  }

  Future<void> _fetchEmployeeProfile() async {
    if (empCode == null || empCode!.isEmpty) {
      debugPrint('Employee code is null or empty');
      setState(() => isLoading = false);
      return;
    }

    try {
      final result = await _client.getEmployeeProfile(empCode!);
      logger.d('Result: $result');

      if (result != null) {
        setState(() {
          isLoading = false;
          empCode = result.sapEmpNo;
          empName = result.sapShortName;
          empGrade = result.sapCurrGradeDesc;
          empEmail = result.sapEmail;
          empDobDate = result.sapDob?.toString();
          empMobileNo = result.sapMobileNo;
          empCompany = result.sapCompany;
          empWorkLocation = result.workLocationDescription;
          empCostCenter = result.sapCostCenter;
          empRetirementDate = result.sapRetirementDate?.toString();
          empCluster = result.hrclText;
          empDepartment = result.sapCurrJobDesc;
          empCompanyCode = result.sbuText;
        });

        await LocalPrefs.saveEmployeeProfile(
          empName: empName,
          empEmail: empEmail?.toLowerCase(),
          empMobile: empMobileNo,
          empGrade: empGrade,
          empCostCenter: empCostCenter?.toString(),
        );
      } else {
        debugPrint('Employee profile not found');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching employee profile: $e');
      setState(() => isLoading = false);
    }
  }

  // ==================== REQUEST BODY BUILDERS ====================

  /// Prepares the new employee data payload
  Map<String, dynamic> _bindNewEmployeeRequestBody() {
    return {
      "emp_id": empCode,
      "name": empName,
      "grade": empGrade,
      "email": empEmail,
      "dob": empDobDate,
      "contact": empMobileNo,
      "company": empCompany,
      "worklocation": empWorkLocation,
      "eligibility": empEligibility,
      "cost_centre": empCostCenter,
      "retirement_date": empRetirementDate,
      "cluster": empCluster,
      "department": empDepartment,
      "company_code": empCompanyCode,
    };
  }

  /// Prepares the vehicle request payload from form inputs
  Map<String, dynamic> _bindCreateVehicleRequestBody() {
    return {
      "emp_id": empCode,
      "car_model": _vehicleModelCtrl.text.trim(),
      "manufacturer": _manufacturerCtrl.text.trim(),
      "purpose": "Official Use",
      "choice_of_lease": "Employee Official Purpose",
      "color_choice": _colourCtrl.text.trim(),
      "vehicle_type": selectedVehicleType,
      "quotation": double.tryParse(quotationAmountModalResult ?? '0') ?? 0.0, // ✅ Convert to number
      "cooling_period": DateTime.now()
          .toUtc()
          .add(const Duration(days: 90))
          .toIso8601String(),
      "updated_by": empCode,
      "comments": _commentsCtrl.text.trim().isEmpty
          ? null
          : _commentsCtrl.text.trim(), // ✅ Send null if empty
    };
  }

  /// Prepares the document upload payload
  Map<String, dynamic> _bindUploadDocRequestBody() {
    if (uploadedQuotationFile == null) {
      throw Exception('No file selected');
    }

    // ✅ Validate that bytes are available
    if (uploadedQuotationFile!.bytes == null) {
      throw Exception('File data not available. Please select the file again.');
    }

    return {
      'emp_id': empCode,
      'process_stage': Stage.requested?.stageNo ?? 20,
      'doc_id': (Document.initialQuotationDoc?.docId ?? 1).toString(), // Document ID for quotation
      'files': [
        MultipartFile.fromBytes(
          uploadedQuotationFile!.bytes!,
          filename: uploadedQuotationFile!.name,
        ),
      ],
    };
  }

  // ==================== VALIDATION ====================

  /// Validates all required fields before submission
  bool _validateBeforeSubmit() {
    // Document validation
    if (uploadedQuotationFile == null) {
      _showValidationToast('Upload Quotation document');
      return false;
    }

    // Manufacturer validation
    if (_manufacturerCtrl.text.trim().isEmpty) {
      _showValidationToast('Please enter manufacturer');
      return false;
    }

    // Vehicle model validation
    if (_vehicleModelCtrl.text.trim().isEmpty) {
      _showValidationToast('Please enter vehicle model');
      return false;
    }

    // Color validation
    if (_colourCtrl.text.trim().isEmpty) {
      _showValidationToast('Please enter Vehicle color');
      return false;
    }

    // Vehicle type validation
    if (selectedVehicleType == null || selectedVehicleType!.isEmpty) {
      _showValidationToast('Please select vehicle type');
      return false;
    }

    // Quotation validation
    if (quotationAmountModalResult == '0' || quotationAmountModalResult!.isEmpty) {
      _showValidationToast('Open Quotation Form modal and fill the data');
      return false;
    }

    return true;
  }

  // ==================== SUBMISSION HANDLERS ====================

  /// Main submission handler - orchestrates the three-step process
  Future<void> _handleSubmit() async {
    try {
      // STEP 1
      final newEmpRequestBody = _bindNewEmployeeRequestBody();
      final response1 = await _client.createNewEmployee(newEmpRequestBody);
      logger.d('Updating Employee: $response1');

      // STEP 2
      final carRequestBody = _bindCreateVehicleRequestBody();
      final response2 = await _client.createNewVehicleRequest(carRequestBody);
      logger.d('New Request created: $response2');
      if (!mounted) return;

      // Exit screen immediately
      Navigator.pop(context);
      // STEP 3 (fire & forget)
      _handleUploadSafely();

    } catch (e) {
      logger.e('Error during submission: $e');
      if (!mounted) return;
    }
  }

  void _handleUploadSafely() {
    Future(() async {
      try {
        await _handleUpload();
        logger.d("Upload completed in background");
      } catch (e) {
        logger.e("Background upload failed: $e");
      }
    });
  }

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

  // ==================== UI HELPERS ====================

  void _showQuotationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuotationFormModal(
        onConfirm: (amount) {
          setState(() {
            quotationAmountModalResult = amount;
          });
        },
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
          'Create Request',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicle Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2ECC71),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Manufacturer
                    FormTextField(
                      label: 'Manufacturer',
                      hint: 'Enter Manufacturer',
                      required: true,
                      controller: _manufacturerCtrl,
                    ),
                    const SizedBox(height: 20),

                    // Vehicle Model
                    FormTextField(
                      label: 'Vehicle Model',
                      hint: 'Enter Vehicle Model',
                      required: true,
                      controller: _vehicleModelCtrl,
                    ),
                    const SizedBox(height: 20),

                    // Colour
                    FormTextField(
                      label: 'Colour',
                      hint: 'Enter Vehicle colour',
                      required: true,
                      controller: _colourCtrl,
                    ),
                    const SizedBox(height: 20),

                    // Vehicle Type
                    DropdownField(
                      label: 'Vehicle Type',
                      hints: 'Select Vehicle Type',
                      items: const ["Petrol", "Diesel", "EV", "Hybrid", "CNG"],
                      required: true,
                      onChanged: (value) {
                        setState(() {
                          selectedVehicleType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Comments
                    FormTextField(
                      label: 'Comments',
                      hint: 'Your Comments',
                      maxLines: 3,
                      controller: _commentsCtrl,
                    ),
                    const SizedBox(height: 20),

                    // Upload Document
                    FileUploadField(
                      label: 'Upload Quotation Document',
                      allowedExtensions: const ['pdf', 'xls', 'xlsx', 'docx', 'jpg', 'png'],
                      onFileSelected: (file) {
                        setState(() {
                          uploadedQuotationFile = file;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Quotation Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _showQuotationModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xF5323232),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Calculate Quotation Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quotation Amount Display
                    DetailRow(
                      label: 'Quotation Amount (₹)',
                      value: '₹ $quotationAmountModalResult',
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isUploading
                      ? null
                      : () async {
                    // if (!_formKey.currentState!.validate()) return;
                    if (!_validateBeforeSubmit()) return;
                    try {
                      setState(() {
                        _isUploading = true;
                      });

                      await _handleSubmit();
                      // Navigator.pop(context);
                      _showSnackBar(message: "New Request Created successfully", isSuccess: true);
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isUploading = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}