import 'package:flutter/material.dart';

import '../../network/api_models/car_request.dart';
import '../../network/api_models/admin_page_response.dart';
import '../../network/api_client.dart';
import '../../constants/local_prefs.dart';

import '../../core/utils/enum.dart';
import '../../core/utils/role_stage_policy.dart';
import '../../core/helpers/normalize.dart';
import '../profile/profile_page.dart';
import '../../custom/widgets/custom_search_bar.dart';
import '../../custom/widgets/request_card.dart';
import '../../custom/modals/delete_request_modal.dart';

class SearchScreen extends StatefulWidget {
  final UserRole role;

  SearchScreen({
    Key? key,
    required this.role,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String selectedFilter = 'Active';
  AdminPageResponse? adminPageResponse;
  Map<Stage, List<CarRequest>> stageRequests = {};
  final ApiClient _client = ApiClient();
  bool isLoading = false; // ✅ Added missing variable

  @override
  void initState() {
    super.initState();
    _loadAllRequestsForUserRole();
  }

  Future<void> _loadAllRequestsForUserRole() async {
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
          role: widget.role, // ✅ Use widget.role instead of calculating it
        );
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching admin page data: $e');
      setState(() => isLoading = false);
    }
  }

  void _showDeleteRequestModal(BuildContext context, CarRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeleteRequestModal(request: request),
    );
  }

  // ✅ Get all requests for stages allowed for the current role
  List<CarRequest> get allRequests {
    List<CarRequest> requests = [];

    // Get allowed stages for this role from RoleStagePolicy
    final allowedStagesForRole = RoleStagePolicy.allowedStages[widget.role] ?? [];

    // Collect requests from all allowed stages
    for (var stage in allowedStagesForRole) {
      requests.addAll(stageRequests[stage] ?? []);
    }

    return requests;
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
          'Search',
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
            padding: const EdgeInsetsGeometry.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // Search Bar
                CustomSearchBar(),
                const SizedBox(height: 8),
                // Filter Buttons
                Row(
                  children: [
                    _buildFilterButton(label: 'Active',isSelected: selectedFilter == 'Active', activeColor: Color.fromRGBO(
                        215, 255, 216, 1.0), activeTextColor:  Color.fromRGBO(23, 86, 26, 1.0), onTap: () {
                      setState(() {
                        selectedFilter = 'Active';
                      });
                    },),
                    const SizedBox(width: 8),
                    _buildFilterButton(label: 'Inactive', isSelected: selectedFilter == 'Inactive', activeColor:  Color.fromRGBO(
                        255, 227, 227, 1.0), activeTextColor:  Color.fromRGBO(86, 23, 23, 1.0), onTap: () {
                      setState(() {
                        selectedFilter = 'Inactive';
                      });
                    },),
                  ],
                ),
              ],
            ),
          ),
          // Scrollable Request Cards
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : allRequests.isEmpty
                ? const Center(
              child: Text(
                'No Requests',
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
              itemCount: allRequests.length,
              itemBuilder: (context, index) {
                final request = allRequests[index];
                return RequestCard(
                  request: request,
                  onTap: () {
                    _showDeleteRequestModal(context, request);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color activeColor = Colors.black,
    Color activeTextColor = Colors.white,
    Color inactiveColor = const Color.fromRGBO(255, 255, 255, 1.0),
    Color inactiveTextColor = Colors.black45,
    EdgeInsetsGeometry padding =
    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    double borderRadius = 20,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: isSelected ? activeColor : Color.fromRGBO(
              227, 227, 227, 1.0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            color: isSelected ? activeTextColor : inactiveTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

}