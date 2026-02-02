import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/local_prefs.dart';
import '../../network/api_client.dart';
import '../../custom/widgets/file_uploader.dart';
import '../../custom/modals/quotation_form_modal.dart';
import '../../custom/widgets/form_text_field.dart';
import '../../custom/widgets/file_uploader.dart';
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

  String empId = '';
  String? quotationAmountModalResult = '0';
  final _manufacturerCtrl = TextEditingController();
  final _vehicleModelCtrl = TextEditingController();
  final _colourCtrl = TextEditingController();
  final _commentsCtrl = TextEditingController();
  String? selectedVehicleType;
  bool isLoading = true;

  // Employee data
  String? empName;
  String? empEmail;
  String? empCode;
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

  // Step 0: load empCode & empEligibility
  Future<void> _loadEmpCodeAndEligibility() async {
    empCode = await LocalPrefs.getEmpCode();
    empEligibility = await LocalPrefs.getEmpEligibility();
  }

  // Step 1: Fetch employee profile
  Future<void> _fetchEmployeeProfile() async {
    if (empCode == null || empCode!.isEmpty) {
      debugPrint('Employee code is null or empty');
      setState(() => isLoading = false);
      return;
    }

    try {
      final result = await _client.getEmployeeProfile(empCode!);

      if (result != null) {
        setState(() {
          isLoading = false;
          empCode = result.sapEmpNo;
          empName = result.sapShortNameModify;
          empGrade = result.sapCurrGradeDesc;
          empEmail = result.sapEmail;
          empDobDate = result.sapDob?.toString();
          empMobileNo = result.sapMobileNo;
          empCompany = result.sapCompany;
          empWorkLocation = result.workLocationDescription;
          empEligibility = empEligibility;
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
        setState(() => isLoading = false); //
      }
    } catch (e) {
      debugPrint('Error fetching employee profile: $e');
      setState(() => isLoading = false);
    }
  }

  // Step 2: Call the newEmployee: to validate the existent User request
  // 2.1)
  Map<String, dynamic> _buildNewEmployeeRequestBody() {
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
  // 2.2) REQUEST BODY
  Future<void> _createNewEmployee() async {
    final requestBody = _buildNewEmployeeRequestBody();
    final response = await _client.createNewEmployee(requestBody);
    print(response.message);
  }


  // Step 3: Bind the inputs from the "Create Request" form fields
  Map<String, dynamic> _buildCreateVehicleRequestBody(String empId) {
    return {
      "emp_id": empId,
      "car_model": _vehicleModelCtrl.text.trim(),
      "manufacturer": _manufacturerCtrl.text.trim(),
      "purpose": "Official Use",
      "choice_of_lease": "Employee Official Purpose",
      "color_choice": _colourCtrl.text.trim(),
      "vehicle_type": selectedVehicleType,
      "quotation": quotationAmountModalResult,
      "cooling_period": "90 days",
      "updated_by": empId,
      "comments": _commentsCtrl.text.trim(),
    };
  }


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
                      items: ["Petrol", "Diesel", "EV", "Hybrid", "CNG"],
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

                    FileUploadField(label: 'Upload Quotation Document', allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],),
                    const SizedBox(height: 24),

                    // Process_stage & Doc_id Logic

                    // Calculate Quotation Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _showQuotationModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C2C2C),
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
                    DetailRow(label: 'Quotation Amount (₹)', value: '₹ $quotationAmountModalResult'),
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
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    try {
                      final code = await LocalPrefs.getEmpCode();
                      setState(() {
                        empId = code ?? '';
                      });

                      final requestBody = _buildCreateVehicleRequestBody(empId);

                      final response =
                      await ApiClient().createNewVehicleRequest(requestBody);

                      if (!mounted) return;

                      _showSnackBar(
                        context: context,
                        message: response.message.toString(),
                        isSuccess: true,
                      );

                      Navigator.pop(context, true);
                    } catch (e) {
                      if (!mounted) return;

                      _showSnackBar(
                        context: context,
                        message: e.toString(),
                        isSuccess: false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14), // 👈 extra comfort
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
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

  // Widget Specifics
  void _showQuotationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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

  // Sends the requestBody to the ApiClient.createNewVehicleRequest function
  Future<void> _submitRequest() async {
    final requestBody = _buildCreateVehicleRequestBody(empId);

    final response =
    await _client.createNewVehicleRequest(requestBody);

    print(response.message);
  }

  @override
  void dispose() {
    _manufacturerCtrl.dispose();
    _vehicleModelCtrl.dispose();
    _colourCtrl.dispose();
    _commentsCtrl.dispose();
    super.dispose();
  }
}
