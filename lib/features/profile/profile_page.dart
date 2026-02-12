import 'package:flutter/material.dart';
import '../../network/api_client.dart';
import '../../network/api_models/role_by_employee.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_models/employee_profile_data.dart';
import '../request/request_vehicle.dart';
import '../../constants/local_prefs.dart';
import 'dart:async';
import 'dart:core';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// Employee Profile Page
class _ProfilePageState extends State<ProfilePage> {
  final ApiClient _client = ApiClient();

  // int? roleId;
  bool isLoading = true;
  String? employeeName;
  String? employeeCode;
  String? employeeMobileNo;
  String? employeeEmail;
  String? employeeCompany;
  String? employeeGrade;
  String? employeeEligibility;
  String? employeeCostCenter;
  String? employeeAddress;
  String? employeeCluster;

  CarRequest? employeeRequest;
  final List<CarRequest> activeRequests = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadEmpCode();
    await _fetchEmployeeProfile();
    await _loadEmpEligibility();
    await _loadFilterBasedRequests();
  }
  // Load Employee Code
  Future<void> _loadEmpCode() async {
    employeeCode = await LocalPrefs.getEmpCode();
  }

  // Employee Details
  Future<void> _fetchEmployeeProfile() async {
    if (employeeCode == null || employeeCode!.isEmpty) {
      debugPrint('Employee code is null or empty');
      setState(() => isLoading = false);
      return;
    }

    try {
      final result = await _client.getEmployeeProfile(employeeCode!);

      if (result != null) {
        setState(() {
          isLoading = false;
          employeeName = result.sapShortNameModify;
          employeeMobileNo = result.sapMobileNo;
          employeeEmail = result.sapEmail;
          employeeCompany = result.sapCompanyDesc;
          employeeGrade = result.sapCurrGradeDesc;
          employeeCostCenter = result.sapCostCenter;
          employeeAddress = result.workLongTxt;
          employeeCluster = result.hrclText;
        });

        await LocalPrefs.saveEmployeeProfile(
          empName: employeeName,
          empEmail: employeeEmail?.toLowerCase(),
          empMobile: employeeMobileNo,
          empGrade: employeeGrade,
          empCostCenter: employeeCostCenter?.toString(),
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

  // Load Eligibility from Local Prefs
  Future<void> _loadEmpEligibility() async {
    employeeEligibility = await LocalPrefs.getEmpEligibility();
    setState(() {});
  }

  Future<void> _loadFilterBasedRequests() async {
    setState(() {
      isLoading = true;
    });

    // 1️⃣ Load from LocalPrefs
    final empId = await LocalPrefs.getEmpCode();
    final roleId = await LocalPrefs.getRoleId();

    if (empId == null || empId.isEmpty) {
      debugPrint('Employee ID is null or empty');
      setState(() => isLoading = false);
      return;
    }

    if (roleId == null) {
      debugPrint('Role ID is null - check LocalPrefs');
      setState(() => isLoading = false);
      return;
    }

    try {
      // 2️⃣ API call (NEW endpoint)
      final response = await _client.getStatusFilteredRequests(
        empId: empId,
        role: roleId,
      );

      // 3️⃣ Update state
      setState(() {
        activeRequests
          ..clear()
          ..addAll(response.active);


        isLoading = false;
      });

      if (activeRequests.isNotEmpty) {
        setState(() {
          employeeRequest = activeRequests.firstWhere(
                  (request) => request.empId == empId
          );
        });
      }
    } catch (e) {
      debugPrint('Error fetching status-filtered requests: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color.fromRGBO(34, 197, 94, 1), // Your green color
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VehicleDetailsPage(),
                ),
              );
            },
            child: const Text(
              'Next →',
              style: TextStyle(
                color: Color.fromRGBO(0, 122, 255, 1),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Employee Details',
                style: TextStyle(
                  color: Color.fromRGBO(34, 197, 94, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(minWidth: double.infinity),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    ProfileField(
                      label: 'Name',
                      value: employeeName,
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Employee code',
                      value: employeeCode,
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Mobile No',
                      value: employeeMobileNo,
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Email',
                      value: employeeEmail?.toLowerCase(),
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Company',
                      value: employeeCompany,
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Grade',
                      value: employeeGrade,
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Eligibility',
                      value: employeeEligibility,
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Cost Center',
                      value: employeeCostCenter,
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ExpandableAddressField(
                      label: 'Address',
                      value: employeeAddress,
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Cluster',
                      value: employeeCluster,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Profile Field Widget
class ProfileField extends StatelessWidget {
  final String label;
  final String? value;
  final bool isLast;

  const ProfileField({
    Key? key,
    required this.label,
    required this.value,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: 56,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Color.fromRGBO(156, 163, 175, 1),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              (value == null || value!.isEmpty) ? '-' : value!,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color.fromRGBO(17, 24, 39, 1),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Address Field Widget
class ExpandableAddressField extends StatefulWidget {
  final String label;
  final String? value;
  final int collapsedLines;

  const ExpandableAddressField({
    Key? key,
    required this.label,
    required this.value,
    this.collapsedLines = 2,
  }) : super(key: key);

  @override
  State<ExpandableAddressField> createState() =>
      _ExpandableAddressFieldState();
}
class _ExpandableAddressFieldState extends State<ExpandableAddressField> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final displayValue =
    (widget.value == null || widget.value!.isEmpty)
        ? '-'
        : widget.value!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Label
          Expanded(
            flex: 2,
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Color.fromRGBO(156, 163, 175, 1),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
              ),
            ),
          ),

          const SizedBox(width: 16),

          /// Address + View More
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Text(
                    displayValue,
                    maxLines:
                    _expanded ? null : widget.collapsedLines,
                    overflow:
                    _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    softWrap: true,
                    style: const TextStyle(
                      color: Color.fromRGBO(17, 24, 39, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                  ),
                ),

                /// View more / less
                if (displayValue != '-' &&
                    displayValue.length > 60)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _expanded = !_expanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _expanded ? 'View less' : 'View more',
                          style: const TextStyle(
                            color: Color.fromRGBO(37, 99, 235, 1), // blue-600
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Vehicle Details Page - Now a StatefulWidget
class VehicleDetailsPage extends StatefulWidget {
  const VehicleDetailsPage({Key? key}) : super(key: key);

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  final ApiClient _client = ApiClient();

  // Employee Vehicle Request (if exist i.e. Active Request)
  CarRequest? employeeRequest;
  final List<CarRequest> activeRequests = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilterBasedRequests();
  }

  // Check for Active request - Same logic as dashboard_main.dart
  Future<void> _loadFilterBasedRequests() async {
    setState(() {
      isLoading = true;
    });

    // 1️⃣ Load from LocalPrefs
    final empId = await LocalPrefs.getEmpCode();
    final roleId = await LocalPrefs.getRoleId();

    if (empId == null || empId.isEmpty) {
      debugPrint('Employee ID is null or empty');
      setState(() => isLoading = false);
      return;
    }

    if (roleId == null) {
      debugPrint('Role ID is null - check LocalPrefs');
      setState(() => isLoading = false);
      return;
    }

    try {
      // 2️⃣ API call
      final response = await _client.getStatusFilteredRequests(
        empId: empId,
        role: roleId,
      );

      // 3️⃣ Update state
      setState(() {
        activeRequests
          ..clear()
          ..addAll(response.active);

        isLoading = false;
      });

      if (activeRequests.isNotEmpty) {
        setState(() {
          employeeRequest = activeRequests.firstWhere(
                  (request) => request.empId == empId
          );
        });
      }
    } catch (e) {
      debugPrint('Error fetching status-filtered requests: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color.fromRGBO(34, 197, 94, 1), // Your green color
          ),
        ),
      );
    }

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
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Details',
              style: TextStyle(
                color: Color.fromRGBO(34, 197, 94, 1),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 16),

            // Show request data if there's an active request, otherwise show "Request a Vehicle"
            if (employeeRequest != null) ...[
              // Display Vehicle Request Details
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    constraints: const BoxConstraints(minWidth: double.infinity),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ProfileField(
                          label: 'Request ID',
                          value: employeeRequest!.requestId,
                        ),
                        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                        ProfileField(
                          label: 'Manufacturer',
                          value: employeeRequest!.manufacturer,
                        ),
                        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                        ProfileField(
                          label: 'Car Model',
                          value: employeeRequest!.carModel,
                        ),
                        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                        ProfileField(
                          label: 'Color Choice',
                          value: employeeRequest!.colorChoice,
                        ),
                        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                        ProfileField(
                          label: 'Choice of Lease',
                          value: employeeRequest!.choiceOfLease,
                        ),
                        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                        ProfileField(
                          label: 'Purpose',
                          value: employeeRequest!.purpose,
                        ),
                        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                        ProfileField(
                          label: 'Vehicle Type',
                          value: employeeRequest!.vehicleType,
                        ),
                        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                        ProfileField(
                          label: 'Stage',
                          value: employeeRequest!.stageName,
                        ),
                        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                        ProfileField(
                          label: 'Status',
                          value: employeeRequest!.recordStatusName,
                        ),
                        if (employeeRequest!.quotation != null) ...[
                          const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                          ProfileField(
                            label: 'Quotation',
                            value: '₹${employeeRequest!.quotation?.toStringAsFixed(2)}',
                          ),
                        ],
                        if (employeeRequest!.emiAmount != null) ...[
                          const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                          ProfileField(
                            label: 'EMI Amount',
                            value: '₹${employeeRequest!.emiAmount?.toStringAsFixed(2)}',
                          ),
                        ],
                        if (employeeRequest!.completeEmiTenure != null) ...[
                          const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                          ProfileField(
                            label: 'EMI Tenure',
                            value: '${employeeRequest!.completeEmiTenure} months',
                          ),
                        ],
                        if (employeeRequest!.poNumber != null) ...[
                          const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                          ProfileField(
                            label: 'PO Number',
                            value: employeeRequest!.poNumber,
                            isLast: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Show "Request a Vehicle" section when no active request
              const SizedBox(height: 24),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'You haven\'t registered for any Vehicle yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromRGBO(17, 24, 39, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VehicleRequestPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(
                              124, 209, 127, 1.0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Request a Vehicle',
                          style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 1.0),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}