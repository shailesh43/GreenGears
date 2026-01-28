import 'package:flutter/material.dart';
import 'dart:core';
import '../../custom/widgets/drop_down.dart';
import '../../custom/widgets/request_card.dart';
import '../../custom/widgets/custom_search_bar.dart';
import '../../custom/modals/assign_esna_card_modal.dart';

import '../../network/api_client.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_models/admin_page_response.dart';
import '../../network/api_models/list_of_esna_model.dart';
import '../../core/utils/enum.dart';
import '../../constants/local_prefs.dart';
import '../../core/helpers/normalize.dart';

class AssignEsnaScreen extends StatefulWidget {
  const AssignEsnaScreen({Key? key}) : super(key: key);

  @override
  State<AssignEsnaScreen> createState() => _AssignEsnaScreenState();
}

class _AssignEsnaScreenState extends State<AssignEsnaScreen> {
  final ApiClient _client = ApiClient();

  AdminPageResponse? adminPageResponse;
  Map<Stage, List<CarRequest>> stageRequests = {};
  bool isLoading = true;

  List<GetListOfEsnaModel> esnaList = [];
  List<String> esnaNames = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _loadAssignEsnaScreenRequests();
    _loadEsnaList();
  }

  Future<void> _loadAssignEsnaScreenRequests() async {
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

  Future<void> _loadEsnaList() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _client.getListOfEsna();

      setState(() {
        esnaList = response;

        // Extract only sap_short_name for dropdown
        esnaNames = response
            .map((e) => e.shortName)
            .toList();

        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching ESNA list: $e');
      setState(() => isLoading = false);
    }
  }

  List<CarRequest> get requestedStageRequests =>
      stageRequests[Stage.requested] ?? [];


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
          'Assign ES&A spoc',
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
                CustomSearchBar(),
              ],
            ),
          ),
          // Scrollable Request Cards
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : requestedStageRequests.isEmpty
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
              itemCount: requestedStageRequests.length,
              itemBuilder: (context, index) {
                final request = requestedStageRequests[index];
                return RequestCard(
                  request: request,
                  onTap: () {
                    _showRequestDetailsModal(context, request);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestDetailsModal(
      BuildContext context,
      CarRequest request,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignEsnaCardModal(request: request, esnaList: esnaNames),
    );
  }
}
