import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/enum.dart';
import '../../constants/local_prefs.dart';
import '../../core/helpers/normalize.dart';
import '../../network/api_client.dart';
import '../../network/api_models/car_request.dart';
import '../../network/api_models/admin_page_response.dart';
// Customs
import '../../custom/widgets/request_card.dart';
import '../../custom/modals/request_verification_modal.dart';
import '../../custom/modals/monthly_deduction_modal.dart';
import '../../custom/modals/payment_details_modal.dart';
import '../../custom/modals/rto_tax_receipt_modal.dart';

class EsnaSpocScreen extends StatefulWidget {
  const EsnaSpocScreen({Key? key}) : super(key: key);
  @override
  State<EsnaSpocScreen> createState() => _EsnaSpocScreenState();
}

class _EsnaSpocScreenState extends State<EsnaSpocScreen> {
  final ApiClient _client = ApiClient();

  int _selectedTabIndex = 0;
  AdminPageResponse? adminPageResponse;
  Map<Stage, List<CarRequest>> stageRequests = {};

  List<CarRequest> get assignedToEsnaRequests =>
      stageRequests[Stage.assignedToEsna] ?? [];
  List<CarRequest> get emiCalculationRequests =>
      stageRequests[Stage.emiCalculation] ?? [];
  List<CarRequest> get paymentDetailsRequests =>
      stageRequests[Stage.paymentDetails] ?? [];
  List<CarRequest> get rtoTaxReceiptRequests =>
      stageRequests[Stage.rtoTaxReceipt] ?? [];

  bool isLoading = true;
  final List<String> _tabs = [
    'Request Verification',
    'Monthly deduction',
    'Payment details',
    'RTO tax receipt',
  ];

  // ✅ Map tab index to Stage
  Stage _getStageForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return Stage.assignedToEsna; // 21
      case 1:
        return Stage.emiCalculation; // 24
      case 2:
        return Stage.paymentDetails; // 26
      case 3:
        return Stage.rtoTaxReceipt; // 27
      default:
        return Stage.assignedToEsna;
    }
  }

  // ✅ Get filtered requests based on selected tab
  List<CarRequest> get filteredRequests {
    final stage = _getStageForTab(_selectedTabIndex);
    return stageRequests[stage] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _loadEsnaSpocScreenRequests();
  }

  Future<void> _loadEsnaSpocScreenRequests() async {
    setState(() {
      isLoading = true;
    });

    // 1️⃣ Load from LocalPrefs
    final empId = await LocalPrefs.getEmpCode();
    final roleId = await LocalPrefs.getRoleId();

    debugPrint('Fetching admin page data - empId: $empId, roleId: $roleId');

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

  // ✅ Show modal based on Stage
  void _showModal(BuildContext context, CarRequest request) {
    final stage = _getStageForTab(_selectedTabIndex);

    switch (stage) {
      case Stage.assignedToEsna:
        _showRequestVerificationModal(context, request);
        break;
      case Stage.emiCalculation:
        _showMonthlyDeductionModal(context, request);
        break;
      case Stage.paymentDetails:
        _showPaymentDetailsModal(context, request);
        break;
      case Stage.rtoTaxReceipt:
        _showRtoTaxReceiptModal(context, request);
        break;
      default:
        break;
    }
  }

  void _showRequestVerificationModal(
      BuildContext context,
      CarRequest request,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RequestVerificationModal(request: request),
    );
  }

  void _showMonthlyDeductionModal(
      BuildContext context,
      CarRequest request,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MonthlyDeductionModal(request: request),
    );
  }

  void _showPaymentDetailsModal(
      BuildContext context,
      CarRequest request,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentDetailsModal(request: request),
    );
  }

  void _showRtoTaxReceiptModal(
      BuildContext context,
      CarRequest request,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RtoTaxReceiptModal(request: request),
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
          'ES&A spoc',
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              _tabs[_selectedTabIndex],
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF59BF5C),
              ),
            ),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedTabIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color.fromRGBO(224, 255, 225, 1.0)
                          : const Color(0xFFFFFEFE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF98FC9B)
                            : Color.fromRGBO(217, 217, 217, 1.0),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Color.fromRGBO(66, 179, 71, 1.0)
                              : const Color.fromRGBO(90, 90, 90, 1.0),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF59BF5C),
              ),
            )
                : AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: filteredRequests.isEmpty
                  ? Center(
                key: ValueKey<String>('empty_$_selectedTabIndex'),
                child: const Text(
                  'No pending request',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              )
                  : ListView.builder(
                key: ValueKey<int>(_selectedTabIndex),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredRequests.length,
                itemBuilder: (context, index) {
                  final request = filteredRequests[index];
                  return RequestCard(
                    request: request,
                    onTap: () {
                      _showModal(context, request);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
