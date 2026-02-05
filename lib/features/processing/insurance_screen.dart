import 'package:flutter/material.dart';
import 'dart:core';
import '../../custom/widgets/drop_down.dart';
import '../../custom/widgets/request_card.dart';
import '../../custom/widgets/custom_search_bar.dart';
import '../../custom/modals/insurance_screen_modal.dart';

import '../../network/api_client.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_models/admin_page_response.dart';
import '../../core/utils/enum.dart';
import '../../constants/local_prefs.dart';
import '../../core/helpers/normalize.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({Key? key}) : super(key: key);

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> {

  final ApiClient _client = ApiClient();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  AdminPageResponse? adminPageResponse;
  Map<Stage, List<CarRequest>> stageRequests = {};
  bool isLoading = true;

  List<CarRequest> get assignedToInsuranceStageRequests =>
      stageRequests[Stage.assignedToInsurance] ?? [];

  List<CarRequest> get filteredRequests {
    final baseList = assignedToInsuranceStageRequests;

    if (_searchQuery.isEmpty) {
      return baseList;
    }

    return baseList.where((request) {
      final name = request.employeeName?.toLowerCase() ?? '';
      return name.contains(_searchQuery);
    }).toList();
  }
  // Filter based on the search bar input

  @override
  void initState() {
    super.initState();
    _loadInsuranceScreenRequests();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _loadInsuranceScreenRequests() async {
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
      final response = await _client.getAdminPageData(
        empId: empId,
        roleIds: [roleId],
      );

      // 3️⃣ Process response
      setState(() {
        adminPageResponse = response;
        stageRequests = filterRequestsByRole(
          response: response,
          role: UserRole.fromId(roleId) ?? UserRole.esna,
        );
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching admin page data: $e');
      setState(() => isLoading = false);
    }
  }

  void _showInsuranceScreenModal(
      BuildContext context,
      CarRequest request
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InsuranceScreenModal(request: request),
    );
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
          'Insurance',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsGeometry.fromLTRB(28, 8, 28, 8),
            child: Column(
              children: [
                CustomSearchBar(
                  controller: _searchController,
                  hintText: 'Search by Employee name',
                ),
              ],
            ),
          ),
          // Scrollable Request Cards
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRequests.isEmpty
                ? const Center(
              child: Text(
                'No Pending Requests',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                final request = filteredRequests[index];
                return RequestCard(
                  request: request,
                  onTap: () {
                    _showInsuranceScreenModal(context, request);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
