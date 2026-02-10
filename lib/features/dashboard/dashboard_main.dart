import 'package:flutter/material.dart';

// Pages
import '../request/request_vehicle.dart';
import '../request/user_approval.dart';
import '../request/search_request_vehicle.dart';
import '../request/active_request_page.dart';

// Widgets
import '../docs/uploaded_quotations.dart';
import '../../custom/widgets/action_card.dart';
import '../../custom/widgets/action_card_wide.dart';
import '../../custom/widgets/request_card.dart';
import '../../custom/modals/delete_request_modal.dart';

// Constants
import '../../core/utils/enum.dart';
import '../../network/api_client.dart';
import '../../constants/local_prefs.dart';


import '../../network/api_models/car_request.dart';

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

  // Employee data
  String? empName;
  String? empEmail;
  String? empCode;
  String? empGrade;
  String? empRole;
  String? empCostCenter;
  String? empMobileNo;
  String? empEligibility;

  // Employee Vehicle Request (if exist i.e. Active Request)
  CarRequest? employeeRequest;
  final List<CarRequest> activeRequests = [];


  int roleId = 0;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadEmpCode();
    await LocalPrefs.saveRoleId(roleId: widget.role.id);
    await _fetchEmployeeProfile();
    await _fetchCarEligibility();
    await _loadFilterBasedRequests();
  }
  // 1. Load Employee Code
  Future<void> _loadEmpCode() async {
    empCode = await LocalPrefs.getEmpCode();
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
          empCostCenter = result.sapCostCenter;
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
        await LocalPrefs.saveCarEligibilityPrice(
          price: empEligibility ?? '69',
        );
      } else {
        debugPrint('Car eligibility not found');
      }
    } catch (e) {
      debugPrint('Error fetching car eligibility: $e');
    }
  }
  // 4. Check for Active request
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
    return DashboardScreen(
      empName: empName ?? '',
      empId: empCode ?? '',
      empMail: empEmail ?? '',
      empGrade: empGrade ?? '',
      empRole: empRole ?? '',
      empEligibility: empEligibility ?? '',
      empCostCenter: empCostCenter?? '',
      empMobileNo: empMobileNo ?? '',
      role: widget.role,
      request: employeeRequest,
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
  final String? empCostCenter;
  final String? empMobileNo;
  final UserRole role;
  final CarRequest? request;

  const DashboardScreen({
    super.key,
    required this.empName,
    required this.empId,
    required this.empMail,
    required this.empGrade,
    required this.empRole,
    required this.empEligibility,
    required this.empCostCenter,
    required this.empMobileNo,
    required this.role,
    required this.request,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

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
                          'Welcome,',
                          style: TextStyle(
                            fontSize: 24,
                            letterSpacing: -0.4,
                            color: Color(0xFF000000),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (widget.empName ?? '').split(' ').first,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.4,
                            color: Color(0xFF000000),
                          ),
                        )
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
                                child: _buildInfoItem('Phone', widget.empMobileNo ?? ''),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  'Cost Center',
                                  widget.empCostCenter ?? '',
                                ),
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
                    // Create request only if they
                    Row(
                      children: [
                        Expanded(
                          child: ActionCard(
                          icon: widget.request != null ? Icons.remove_red_eye : Icons.edit,
                            title: widget.request != null
                                ? 'View Your \n Active Request'
                                : 'Create Request\nfor your Vehicle',
                            color: const Color.fromRGBO(41, 183, 69, 0.55),
                            titleColor: const Color.fromRGBO(248, 248, 248, 1.0),
                            iconColor: const Color.fromRGBO(248, 248, 248, 1.0),
                            onTap: () {
                              if (widget.request != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ActiveRequestPage(
                                      request: widget.request!, // ✅ pass request
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const VehicleRequestPage(),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ActionCard(
                            icon: Icons.check_circle_outline,
                            title: 'Approve/Reject\nRequests',
                            color: const Color.fromRGBO(242, 241, 249, 1.0),
                            titleColor: const Color.fromRGBO(152, 152, 152, 1.0),
                            iconColor: const Color.fromRGBO(152, 152, 152, 1.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => UserApproval()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Search Requests
                    if (widget.role?.label != "User") ...[
                      ActionCardWide(
                        icon: Icons.search,
                        title: 'Search Requests',
                        subtitle: 'Browse through all the requests',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchScreen(role: widget.role),
                            ),
                          );
                        },
                      ),
                      const Divider(
                        height: 0.5,
                        thickness: 1,
                        color: Color.fromRGBO(229, 231, 235, 1),
                      ),
                    ],

                    // Quotation docs
                    ActionCardWide(
                      icon: Icons.description_outlined,
                      title: 'Quotation docs',
                      subtitle: 'List of uploaded quotation docs till now',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UploadedQuotations(),
                          ),
                        );
                      },
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
}