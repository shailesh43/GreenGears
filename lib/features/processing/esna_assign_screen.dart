import 'package:flutter/material.dart';
import '../profile/profile_page.dart';

class EsnaAssignScreen extends StatefulWidget {
  const EsnaAssignScreen({Key? key}) : super(key: key);

  @override
  State<EsnaAssignScreen> createState() => _EsnaAssignScreenState();
}

class _EsnaAssignScreenState extends State<EsnaAssignScreen> {
  String selectedFilter = 'Active';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> allRequests = [
    {
      'requestId': 'CAR2025204',
      'vehicleName': 'Himalayan',
      'dateOfRequest': '02/11/2020',
      'contact': '8600957261',
      'status': 'ACTIVE',
      'employeeName': 'Rahil Bopche',
      'employeeId': '209164',
      'phone': '+84549721',
      'company': 'The Tata Power Co. Ltd.',
      'address': 'Technopolis Knowledge Park\n4th floor, Andheri (E),\nMumbai 400093',
      'cluster': 'The Tata Power Co. Ltd.\nCorporate functions\n& International',
      'grade': 'ME03',
      'costCenter': '1900022041',
      'eligibility': '₹ 4300.50',
      'baseAmount': '₹ 40, 500',
      'cessPercentage': '10 %',
      'corporateRegistration': '₹ 2000',
      'quotation': '5 %',
      'total': '₹ 10,00, 000',
      'requestStatus': 'Requested to ES&A',
    },
    {
      'requestId': 'CAR2025205',
      'vehicleName': 'RE Guerilla',
      'dateOfRequest': '23/05/2020',
      'contact': '8600957261',
      'status': 'ACTIVE',
      'employeeName': 'Rahil Bopche',
      'employeeId': '209164',
      'phone': '+84549721',
      'company': 'The Tata Power Co. Ltd.',
      'address': 'Technopolis Knowledge Park\n4th floor, Andheri (E),\nMumbai 400093',
      'cluster': 'The Tata Power Co. Ltd.\nCorporate functions\n& International',
      'grade': 'ME03',
      'costCenter': '1900022041',
      'eligibility': '₹ 4300.50',
      'baseAmount': '₹ 40, 500',
      'cessPercentage': '10 %',
      'corporateRegistration': '₹ 2000',
      'quotation': '5 %',
      'total': '₹ 10,00, 000',
      'requestStatus': 'Requested to ES&A',
    },
    {
      'requestId': 'CAR2025206',
      'vehicleName': 'Triumph Scrambler 400X',
      'dateOfRequest': '18/02/2020',
      'contact': '8600957261',
      'status': 'ACTIVE',
      'employeeName': 'Rahil Bopche',
      'employeeId': '209164',
      'phone': '+84549721',
      'company': 'The Tata Power Co. Ltd.',
      'address': 'Technopolis Knowledge Park\n4th floor, Andheri (E),\nMumbai 400093',
      'cluster': 'The Tata Power Co. Ltd.\nCorporate functions\n& International',
      'grade': 'ME03',
      'costCenter': '1900022041',
      'eligibility': '₹ 4300.50',
      'baseAmount': '₹ 40, 500',
      'cessPercentage': '10 %',
      'corporateRegistration': '₹ 2000',
      'quotation': '5 %',
      'total': '₹ 10,00, 000',
      'requestStatus': 'Requested to ES&A',
    },
    {
      'requestId': 'CAR2025207',
      'vehicleName': 'Honda CBR 650R',
      'dateOfRequest': '15/08/2021',
      'contact': '9876543210',
      'status': 'ACTIVE',
      'employeeName': 'Rahil Bopche',
      'employeeId': '209164',
      'phone': '+84549721',
      'company': 'The Tata Power Co. Ltd.',
      'address': 'Technopolis Knowledge Park\n4th floor, Andheri (E),\nMumbai 400093',
      'cluster': 'The Tata Power Co. Ltd.\nCorporate functions\n& International',
      'grade': 'ME03',
      'costCenter': '1900022041',
      'eligibility': '₹ 4300.50',
      'baseAmount': '₹ 40, 500',
      'cessPercentage': '10 %',
      'corporateRegistration': '₹ 2000',
      'quotation': '5 %',
      'total': '₹ 10,00, 000',
      'requestStatus': 'Requested to ES&A',
    },
    {
      'requestId': 'CAR2025004',
      'vehicleName': 'Maruti Suzuki Swift',
      'dateOfRequest': '18/11/2016',
      'contact': '9140957261',
      'status': 'INACTIVE',
      'employeeName': 'Rahil Bopche',
      'employeeId': '209164',
      'phone': '+84549721',
      'company': 'The Tata Power Co. Ltd.',
      'address': 'Technopolis Knowledge Park\n4th floor, Andheri (E),\nMumbai 400093',
      'cluster': 'The Tata Power Co. Ltd.\nCorporate functions\n& International',
      'grade': 'ME03',
      'costCenter': '1900022041',
      'eligibility': '₹ 4300.50',
      'baseAmount': '₹ 40, 500',
      'cessPercentage': '10 %',
      'corporateRegistration': '₹ 2000',
      'quotation': '5 %',
      'total': '₹ 10,00, 000',
      'requestStatus': 'Requested to ES&A',
    },
    {
      'requestId': 'CAR2025005',
      'vehicleName': 'RE Standard 350',
      'dateOfRequest': '28/04/2018',
      'contact': '8450957261',
      'status': 'INACTIVE',
      'employeeName': 'Rahil Bopche',
      'employeeId': '209164',
      'phone': '+84549721',
      'company': 'The Tata Power Co. Ltd.',
      'address': 'Technopolis Knowledge Park\n4th floor, Andheri (E),\nMumbai 400093',
      'cluster': 'The Tata Power Co. Ltd.\nCorporate functions\n& International',
      'grade': 'ME03',
      'costCenter': '1900022041',
      'eligibility': '₹ 4300.50',
      'baseAmount': '₹ 40, 500',
      'cessPercentage': '10 %',
      'corporateRegistration': '₹ 2000',
      'quotation': '5 %',
      'total': '₹ 10,00, 000',
      'requestStatus': 'Requested to ES&A',
    },
    {
      'requestId': 'CAR2025008',
      'vehicleName': 'Yamaha MT-15',
      'dateOfRequest': '12/09/2019',
      'contact': '7890123456',
      'status': 'INACTIVE',
      'employeeName': 'Rahil Bopche',
      'employeeId': '209164',
      'phone': '+84549721',
      'company': 'The Tata Power Co. Ltd.',
      'address': 'Technopolis Knowledge Park\n4th floor, Andheri (E),\nMumbai 400093',
      'cluster': 'The Tata Power Co. Ltd.\nCorporate functions\n& International',
      'grade': 'ME03',
      'costCenter': '1900022041',
      'eligibility': '₹ 4300.50',
      'baseAmount': '₹ 40, 500',
      'cessPercentage': '10 %',
      'corporateRegistration': '₹ 2000',
      'quotation': '5 %',
      'total': '₹ 10,00, 000',
      'requestStatus': 'Requested to ES&A',
    },
  ];

  List<Map<String, dynamic>> get filteredRequests {
    return allRequests
        .where((request) => request['status'] == selectedFilter.toUpperCase())
        .toList();
  }

  void _showRequestDetailsModal(BuildContext context, Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RequestDetailsModal(request: request),
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
            padding: const EdgeInsetsGeometry.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Requests',
                    hintStyle: const TextStyle(
                      fontFamily: 'Inter',
                      color: Color.fromARGB(255, 158, 158, 158),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Buttons
                Row(
                  children: [
                    _buildFilterButton('Active', Color.fromRGBO(
                        98, 202, 102, 1.0)),
                    const SizedBox(width: 8),
                    _buildFilterButton('Inactive', Color.fromRGBO(
                        250, 77, 77, 1.0)),
                  ],
                ),
              ],
            ),
          ),
          // Scrollable Request Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                return RequestCard(
                  request: filteredRequests[index],
                  onTap: () {
                    _showRequestDetailsModal(context, filteredRequests[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, Color activeColor) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onTap;

  const RequestCard({
    Key? key,
    required this.request,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = request['status'] == 'ACTIVE';
    final statusColor = isActive ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request ID',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  request['requestId'],
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRow('Vehicle Name', request['vehicleName']),
            const SizedBox(height: 8),
            _buildRow('Date of Request', request['dateOfRequest']),
            const SizedBox(height: 8),
            _buildRow('Contact', request['contact']),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  request['status'],
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RequestDetailsModal extends StatelessWidget {
  final Map<String, dynamic> request;

  const _RequestDetailsModal({required this.request});

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Request',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this request?',
            style: TextStyle(
              fontFamily: 'Inter',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color.fromRGBO(128, 128, 128, 1.0),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final requestId = request['requestId'] ?? 'CAR2025242';
                Navigator.of(context).pop();// Close dialog

                // Show snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$requestId has been deleted',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(255, 60, 60, 1.0),
                      ),
                    ),
                    backgroundColor: Color.fromRGBO(255, 227, 227, 1.0),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        request['employeeName'] ?? 'Rahil Bopche',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(context),
                    ),
                  ],
                ),
              ),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(request),
                      const SizedBox(height: 24),
                      _buildDetailRow('Vehicle Name', request['vehicleName'] ?? 'RE Guerilla'),
                      _buildDetailRow('Employee Name', request['employeeName'] ?? 'Rahil Bopche'),
                      _buildDetailRow('Employee ID', request['employeeId'] ?? '209164'),
                      _buildDetailRow('Phone', request['phone'] ?? '+84549721'),
                      _buildDetailRow('Date of Request', request['dateOfRequest'] ?? '01/11/2019'),
                      _buildDetailRow('Company', request['company'] ?? 'The Tata Power Co. Ltd.'),
                      _buildDetailRow(
                        'Address',
                        request['address'] ?? 'Technopolis Knowledge Park\n4th floor, Andheri (E),\nMumbai 400093',
                        isMultiline: true,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Cluster',
                        request['cluster'] ?? 'The Tata Power Co. Ltd.\nCorporate functions\n& International',
                        isMultiline: true,
                      ),
                      _buildDetailRow('Grade', request['grade'] ?? 'ME03'),
                      _buildDetailRow('Cost center', request['costCenter'] ?? '1900022041'),
                      _buildDetailRow('Eligibility', request['eligibility'] ?? '₹ 4300.50'),
                      const Divider(height: 24, thickness: 1),
                      _buildDetailRow('Base Amount', request['baseAmount'] ?? '₹ 40, 500', isBold: true),
                      _buildDetailRow('CESS percentage', request['cessPercentage'] ?? '10 %'),
                      _buildDetailRow('Corporate Registration Amount', request['corporateRegistration'] ?? '₹ 2000'),
                      _buildDetailRow('Quotation Amount', request['quotation'] ?? '5 %'),
                      const SizedBox(height: 16),
                      _buildTotalRow(request),
                      const SizedBox(height: 24),
                      _buildStatusRow(request),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(Map<String, dynamic> request) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Request ID',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Text(
          request['requestId'] ?? 'CAR2025242',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMultiline = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF757575),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(Map<String, dynamic> request) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Text(
          request['total'] ?? '₹ 10,00, 000',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(Map<String, dynamic> request) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'STATUS',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Text(
          request['requestStatus'] ?? 'Requested to ES&A',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2196F3),
          ),
        ),
      ],
    );
  }
}