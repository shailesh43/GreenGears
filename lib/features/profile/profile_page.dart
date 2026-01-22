import 'package:flutter/material.dart';
import '../../network/api_client.dart';
import '../../network/api_models/role_by_employee.dart';
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

  @override
  void initState() {
    super.initState();
    // _fetchRole();
    _init();
  }

  Future<void> _init() async {
    await _loadEmpCode();
    await _fetchEmployeeProfile();
    await _loadEmpEligibility();
  }
  // Load Employee Code
  Future<void> _loadEmpCode() async {
    employeeCode = await LocalPrefs.getEmpCode();
    debugPrint('Employee code loaded: $employeeCode');
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
          // employeeEligibility = result.sapBasic.toString();
          employeeCostCenter = result.sapCostCenter;
          employeeAddress = result.workLongTxt;
          employeeCluster = result.omclText;
        });

        await LocalPrefs.saveEmployeeProfile(
          empName: employeeName,
          empEmail: employeeEmail?.toLowerCase(),
          empMobile: employeeMobileNo,
          empGrade: employeeGrade,
          empCostCenter: employeeCostCenter?.toString(),
        );

        debugPrint('POST 200 OK : "/employees"');
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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

// Vehicle Details Page
class VehicleDetailsPage extends StatelessWidget {
  const VehicleDetailsPage({Key? key}) : super(key: key);

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
            const SizedBox(height: 40),
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
                        backgroundColor: const Color.fromRGBO(34, 197, 94, 1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Request a Vehicle',
                        style: TextStyle(
                          color: Colors.white,
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
        ),
      ),
    );
  }
}
