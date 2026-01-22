import 'package:flutter/material.dart';
import '../request/request_vehicle.dart';
import '../request/user_approval.dart';
import '../../features/profile/profile_page.dart';
import '../request/search_request_vehicle.dart';
import '../docs/uploaded_quotations.dart';
import '../../constants/utils.dart';
import '../../network/api_client.dart';
import '../../constants/local_prefs.dart';

class MainDashboard extends StatefulWidget {
  final UserRole role;

  const   MainDashboard({
    super.key,
    required this.role,
  });

  @override
  State<MainDashboard> createState() => _MainDashboard();
}

class _MainDashboard extends State<MainDashboard> {
  final ApiClient _client = ApiClient();

  // Employee data from local preferences
  String? empName;
  String? empEmail;
  String? empCode;
  String? empGrade;
  String? empRole;
  String? empCostCenter;
  String? empMobileNo;
  String? empEligibility;
  String? empEligibilityNotes;


  int roleId = 0;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadEmpCode();
    await _fetchEmployeeProfile();
    await _fetchCarEligibility();
  }
  // 1. Load Employee Code
  Future<void> _loadEmpCode() async {
    empCode = await LocalPrefs.getEmpCode();
    debugPrint('Employee code loaded: $empCode');
  }
  // 2. Fetch Employee Profile
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
          empName = result.sapShortNameModify;
          empMobileNo = result.sapMobileNo;
          empEmail = result.sapEmail;
          empGrade = result.sapCurrGradeDesc;
          // empEligibility = result.sapBasic.toString();
          empCostCenter = result.sapCostCenterDesc;
        });

        await LocalPrefs.saveEmployeeProfile(
          empName: empName,
          empEmail: empEmail?.toLowerCase(),
          empMobile: empMobileNo,
          empGrade: empGrade,
          // empEligibility: empEligibility?.toString(),
        );
        debugPrint('POST 200 OK : "/employees"');
      } else {
        debugPrint('Employee profile not found');
        setState(() => isLoading = false); //
      }
    } catch (e) {
      debugPrint('Error fetching employee profile: $e');
      setState(() => isLoading = false);
    }
  }
  // 3. Fetch Car Eligibility
  Future<void> _fetchCarEligibility() async {
    // You can also load from LocalPrefs if needed
    final workLevel = empGrade ?? await LocalPrefs.getEmpGrade();

    if (workLevel == null || workLevel.isEmpty) {
      debugPrint('Work level (empGrade) is null or empty');
      return;
    }

    try {
      final price =
      await _client.getCarEligibilityExShowroomPrice(workLevel);

      if (price != null) {
        setState(() {
          empEligibility = price;
        });

        // Optional: save for later use
        await LocalPrefs.saveCarEligibilityPrice(
          price: empEligibility ?? '69',
        );
        debugPrint(
          'Car eligibility ex-showroom price fetched: $price',
        );
      } else {
        debugPrint('Car eligibility not found');
      }
    } catch (e) {
      debugPrint('Error fetching car eligibility: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScreen(
      empName: empName ?? '',
      empId: empCode ?? '',
      empMail: empEmail ?? '',
      empGrade: empGrade ?? '',
      empRole: empRole ?? '',
      empEligibility: empEligibility ?? '',
      empMobileNo: empMobileNo ?? '',
      role: widget.role,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String? empName;
  final String? empId;
  final String? empMail;
  final String? empGrade;
  final String? empRole;
  final String? empEligibility;
  final String? empMobileNo;
  final UserRole? role;
  // final bool isLoading;

  const DashboardScreen({
    super.key,
    required this.empName,
    required this.empId,
    required this.empMail,
    required this.empGrade,
    required this.empRole,
    required this.empEligibility,
    required this.empMobileNo,
    required this.role,
    // required this.isLoading,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // used for testing
  final Map<String, String> mainRequest = {
    // Basic Request Info
    'requestId': 'CAR2025204',
    'vehicleName': 'Himalayan',
    'dateOfRequest': '02/11/2020',
    'contact': '8600957261',
    'status': 'ACTIVE',

    // Employee Details
    'employeeName': 'Rahil Bopche',
    'employeeId': '209164',
    'phone': '+84549721',
    'email': 'rahil.bopche@tatapower.com',

    // Company & Work Details
    'company': 'The Tata Power Co. Ltd.',
    'workLocation': 'Mumbai',
    'address': 'Technopolis Knowledge Park\n4th floor, Andheri (E),\nMumbai 400093',
    'cluster': 'The Tata Power Co. Ltd.\nCorporate functions\n& International',
    'grade': 'ME03',
    'costCenter': '1900022041',

    // Financial Details
    'eligibility': '₹ 40,000',
    'baseAmount': '₹ 40,500',
    'basePremium': '36,460',
    'cessPercentage': '10 %',
    'corporateRegistration': '₹ 2000',
    'quotation': '5 %',
    'total': '₹ 10,00,000',

    // Insurance Details (Stage 23)
    'insuranceType': 'Add on',

    // EMI Details (Stage 25)
    'totalEMI': '36,460',
    'allowance': '13,500',
    'contribution': '3800',
    'tenure': '3 years',

    // Workflow Details
    'requestStatus': 'Requested to ES&A',
    'category': 'Request Verification',
    'comments': 'Approved',
    'assignedTo': 'ES&A SPOC Name',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      extendBodyBehindAppBar: true,
      body: Container(
        child: Column(
          children: [
            // Header
            Container(
              height: 130,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.only(top: 30, bottom: 0),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(41, 183, 69, 1),
                border: Border.all(color: Colors.black, width: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Image.asset(
                        'assets/images/tata_power_logo.png',
                        height: 48,
                        fit: BoxFit.contain,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'GreenGears',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        letterSpacing: -0.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Row(
                      children: [
                        const Text(
                          'Welcome',
                          style: TextStyle(
                            fontSize: 24,
                            letterSpacing: -0.4,
                            color: Color(0xFF000000),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.empName ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.4,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (widget.empMail ?? '').toLowerCase(),
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: -0.2,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.20),
                            offset: const Offset(3, 3),
                            blurRadius: 6,
                            spreadRadius: -1,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem('EMP code', widget.empId ?? ''),
                              ),
                              Expanded(
                                child: _buildInfoItem('Grade', widget.empGrade ?? ''),
                              ),
                              Expanded(
                                child: _buildInfoItem('Role', widget.role?.label ?? '',),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  'Eligibility',
                                  widget.empEligibility ?? '',
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem('Phone', widget.empMobileNo ?? ''),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: Color.fromRGBO(41, 183, 69, 0.50),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.edit,
                            title: 'Create Request\nfor your Vehicle',
                            color: const Color.fromRGBO(41, 183, 69, 0.55),
                            titleColor: const Color.fromRGBO(248, 248, 248, 1.0),
                            iconColor: const Color.fromRGBO(248, 248, 248, 1.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const VehicleRequestPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.check_circle_outline,
                            title: 'Approve/Reject\nRequests',
                            color: const Color.fromRGBO(242, 241, 249, 1.0),
                            titleColor: const Color.fromRGBO(152, 152, 152, 1.0),
                            iconColor: const Color.fromRGBO(152, 152, 152, 1.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserApproval(
                                    stage: 25,
                                    request: mainRequest,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Search Requests
                    if (widget.role?.label != "User") ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.search_rounded,
                                size: 28,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SearchScreen(),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Search Requests',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromRGBO(0, 0, 0, 0.80),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Browse through the requested vehicles',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 0.5,
                        thickness: 1,
                        color: Color.fromRGBO(229, 231, 235, 1),
                      ),
                    ],

                    // Quotation docs
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              size: 28,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UploadedQuotations(),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quotation docs',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(0, 0, 0, 0.80),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'List of uploaded quotation docs till now',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontFamily: 'Inter',
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF000000),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: iconColor ?? Colors.grey, size: 28),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: titleColor ?? Colors.grey,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}