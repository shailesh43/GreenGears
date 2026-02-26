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
                  builder: (context) => EmployeeFeedbackPage(
                    employeeRequest: employeeRequest,
                  ),
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

// Employee Feedback Page - Updated with conditional feedback form
class EmployeeFeedbackPage extends StatefulWidget {
  final CarRequest? employeeRequest;

  const EmployeeFeedbackPage({
    Key? key,
    this.employeeRequest,
  }) : super(key: key);

  @override
  State<EmployeeFeedbackPage> createState() => _EmployeeFeedbackPageState();
}

class _EmployeeFeedbackPageState extends State<EmployeeFeedbackPage> {
  final ApiClient _client = ApiClient();

  // Feedback ratings
  int userExperienceRating = 0;
  int easeOfUseRating = 0;
  int dealerExperienceRating = 0;

  bool isSubmitting = false;

  Future<void> _handleSubmitFeedback() async {
    // Validate that all ratings are provided
    if (userExperienceRating == 0 || easeOfUseRating == 0 || dealerExperienceRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide all ratings before submitting'),
          backgroundColor: Color.fromRGBO(239, 68, 68, 1),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final response = await _client.submitUserFeedback(
        empId: widget.employeeRequest!.empId!,
        requestId: widget.employeeRequest!.requestId!,
        userExperienceRating: userExperienceRating,
        easeOfUseRating: easeOfUseRating,
        dealerExperienceRating: dealerExperienceRating,
      );

      if (!mounted) return;
      _showSnackBar(message: 'Feedback submitted successfully', isSuccess: true);
      Navigator.pop(context, 'Feedback submitted');

    } catch (e) {
      debugPrint('Error submitting feedback: $e');

      if (!mounted) return;
      setState(() {
        isSubmitting = false;
      });
      _showSnackBar(message: 'Failed to submit feedback', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if processStage is 28 (Employee Feedback stage)
    final bool shouldShowFeedback = widget.employeeRequest?.processStage == 28;

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
          'Feedback',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: shouldShowFeedback
          ? _buildFeedbackForm()
          : _buildNoFeedbackScreen(),
    );
  }

  Widget _buildFeedbackForm() {
    return Column(
      children: [
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subheader
                  const Text(
                    'Completed request feedback',
                    style: TextStyle(
                      color: Color.fromRGBO(34, 197, 94, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Request Details Container - More Compact
                  Container(
                    constraints: const BoxConstraints(minWidth: double.infinity),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(248, 250, 252, 1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color.fromRGBO(226, 232, 240, 1),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        _buildCompactField('Request ID', widget.employeeRequest?.requestId),
                        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                        _buildCompactField('Employee ID', widget.employeeRequest?.empId),
                        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                        _buildCompactField('Employee Name', widget.employeeRequest?.employeeName),
                        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                        _buildCompactField('Manufacture By', widget.employeeRequest?.manufacturer),
                        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                        _buildCompactField('Car Model', widget.employeeRequest?.carModel),
                        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                        _buildCompactField('Colour Choice', widget.employeeRequest?.colorChoice),
                        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                        _buildCompactField('Email', widget.employeeRequest?.email?.toLowerCase(), isLast: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Feedback Section with elegant card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromRGBO(255, 255, 255, 1.0),
                          Color.fromRGBO(255, 255, 255, 1.0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color.fromRGBO(246, 246, 246, 1.0),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(
                              226, 229, 227, 0.0784313725490196),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon and Title
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(
                                    150, 165, 156, 0.10196078431372549),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.rate_review,
                                color: Color.fromRGBO(34, 130, 225, 1.0),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Feedback',
                                    style: TextStyle(
                                      color: Color.fromRGBO(17, 24, 39, 1),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Help us improve your experience',
                                    style: TextStyle(
                                      color: Color.fromRGBO(107, 114, 128, 1),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // User Experience Rating
                        _buildEnhancedRatingRow(
                          label: 'User Experience',
                          subtitle: 'How was your overall experience?',
                          rating: userExperienceRating,
                          onRatingChanged: (rating) {
                            setState(() {
                              userExperienceRating = rating;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        // Ease of Use Rating
                        _buildEnhancedRatingRow(
                          label: 'Ease of Use',
                          subtitle: 'Was the process simple and clear?',
                          rating: easeOfUseRating,
                          onRatingChanged: (rating) {
                            setState(() {
                              easeOfUseRating = rating;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        // Dealer Experience Rating
                        _buildEnhancedRatingRow(
                          label: 'Dealer Experience',
                          subtitle: 'Rate your dealer interaction',
                          rating: dealerExperienceRating,
                          onRatingChanged: (rating) {
                            setState(() {
                              dealerExperienceRating = rating;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),

        // Fixed Submit Button at Bottom
        Container(
          padding: const EdgeInsets.all(16),
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
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _handleSubmitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(56, 139, 222, 1.0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Color.fromRGBO(
                      34, 116, 197, 0.5019607843137255),
                ),
                child: isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Submit Feedback',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Compact field widget for request details
  Widget _buildCompactField(String label, String? value, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Color.fromRGBO(107, 114, 128, 1),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              (value == null || value.isEmpty) ? '-' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color.fromRGBO(17, 24, 39, 1),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRatingRow({
    required String label,
    required String subtitle,
    required int rating,
    required Function(int) onRatingChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with asterisk
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color.fromRGBO(17, 24, 39, 1),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: Color.fromRGBO(239, 68, 68, 1),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Subtitle
        Text(
          subtitle,
          style: const TextStyle(
            color: Color.fromRGBO(107, 114, 128, 1),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
          ),
        ),

        const SizedBox(height: 12),

        // Star Rating with better spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return GestureDetector(
              onTap: () => onRatingChanged(starIndex),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    starIndex <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: starIndex <= rating
                        ? const Color.fromRGBO(255, 226, 115, 1.0)
                        : const Color.fromRGBO(203, 213, 225, 1),
                    size: 32,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNoFeedbackScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color.fromRGBO(243, 244, 246, 1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.feedback_outlined,
                size: 64,
                color: Color.fromRGBO(156, 163, 175, 1),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            const Text(
              'No Feedback Available',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(17, 24, 39, 1),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),

            const SizedBox(height: 12),

            // Message
            const Text(
              'Your request is not yet at the feedback stage. Feedback will be available once your vehicle request has been completed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(107, 114, 128, 1),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Additional info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromRGBO(239, 246, 255, 1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color.fromRGBO(191, 219, 254, 1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Color.fromRGBO(59, 130, 246, 1),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Current Stage: ${widget.employeeRequest?.stage?.label ?? 'Unknown'}',
                      style: const TextStyle(
                        color: Color.fromRGBO(30, 64, 175, 1),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
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
}
