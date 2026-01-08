import 'package:flutter/material.dart';
import '../profile/profile_page.dart';

class EsnaAssignScreen extends StatefulWidget {
  const EsnaAssignScreen({Key? key}) : super(key: key);

  @override
  State<EsnaAssignScreen> createState() => _EsnaAssignScreenState();
}

class _EsnaAssignScreenState extends State<EsnaAssignScreen> {
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
      'email': 'rahil.bopche@tatapower.com',
      'costCenter': '1900022041',
      'eligibility': '₹ 40,000',
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
      'email': 'rahil.bopche@tatapower.com',
      'costCenter': '1900022041',
      'eligibility': '₹ 40,000',
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
      'email': 'rahil.bopche@tatapower.com',
      'costCenter': '1900022041',
      'eligibility': '₹ 40,000',
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
      'email': 'rahil.bopche@tatapower.com',
      'costCenter': '1900022041',
      'eligibility': '₹ 40,000',
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
      'email': 'rahil.bopche@tatapower.com',
      'costCenter': '1900022041',
      'eligibility': '₹ 40,000',
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
      'email': 'rahil.bopche@tatapower.com',
      'costCenter': '1900022041',
      'eligibility': '₹ 40,000',
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
      'email': 'rahil.bopche@tatapower.com',
      'costCenter': '1900022041',
      'eligibility': '₹ 40,000',
      'baseAmount': '₹ 40, 500',
      'cessPercentage': '10 %',
      'corporateRegistration': '₹ 2000',
      'quotation': '5 %',
      'total': '₹ 10,00, 000',
      'requestStatus': 'Requested to ES&A',
    },
  ];

  List<Map<String, dynamic>> get filteredRequests {
    return allRequests;
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
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFFFFFFF),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Colors.grey, // 👈 border color
                        width: 0.1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                Text(
                  request['requestId'],
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRow('EMP ID', request['employeeId']),
            const SizedBox(height: 8),
            _buildRow('EMP name', request['employeeName']),
            const SizedBox(height: 8),
            _buildRow('Contact', request['contact']),
            const SizedBox(height: 8),
            _buildRow('Date of Request', request['dateOfRequest']),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
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
                    const SizedBox(width: 40)
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
                      _buildDetailRow(
                          'Vehicle Model', request['vehicleModel'] ?? 'XUV700'),
                      _buildDetailRow('Manufactured by',
                          request['manufacturedBy'] ?? 'Mahindra'),
                      _buildDetailRow(
                          'Color', request['vehicleColor'] ?? 'Black'),
                      _buildDetailRow('Employee Name',
                          request['employeeName'] ?? 'Rahil Bopche'),
                      _buildDetailRow(
                          'Employee ID', request['employeeId'] ?? '209164'),
                      _buildDetailRow('Phone', request['phone'] ?? '+84549721'),
                      _buildDetailRow('Company',
                          request['company'] ?? 'The Tata Power Co. Ltd.'),
                      _buildDetailRow(
                        'Address',
                        request['address'] ??
                            'Technopolis Knowledge Park\n4th floor, Andheri (E),\nMumbai 400093',
                        isMultiline: true,
                      ),
                      _buildDetailRow('Grade', request['grade'] ?? 'ME03'),
                      _buildDetailRow(
                          'Email', request['email'] ?? '1900022041'),
                      _buildDetailRow(
                          'Eligibility', request['eligibility'] ?? '₹ 50,000'),
                      _buildDetailRow(
                          'Quotation Amount', request['total'] ?? '₹ 5,00,000'),
                      const SizedBox(height: 24),

                      // Select ES&A Dropdown
                      const Text(
                        'Select ES&A *',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Select ES&A',
                          hintStyle: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: ['ES&A 1', 'ES&A 2', 'ES&A 3', 'ES&A 4']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          // Handle ES&A selection
                        },
                      ),
                      const SizedBox(height: 16),

                      // View Document Dropdown
                      const Text(
                        'View Document *',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'View Document',
                          hintStyle: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: [
                          'Document 1',
                          'Document 2',
                          'Document 3',
                          'Document 4'
                        ]
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          // Handle document selection
                        },
                      ),
                      const SizedBox(height: 24),

                      // Proceed Button
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final requestId = request['requestId'] ??
                                    'CAR2025242';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'ES&A has been assigned to $requestId',
                                      style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color.fromRGBO(56, 142, 59, 1.0)
                                      ),
                                    ),
                                    backgroundColor: Color.fromRGBO(
                                        215, 255, 216, 1.0),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(89, 191, 92, 1.0),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: const Text(
                                'Proceed',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final requestId = request['requestId'] ??
                                    'CAR2025242';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '$requestId has been rejected.',
                                      style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color.fromRGBO(250, 98, 98, 1.0)
                                      ),
                                    ),
                                    backgroundColor: Color.fromRGBO(
                                        255, 227, 227, 1.0),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(
                                    255, 255, 255, 1.0),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: const Text(
                                'Reject',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromRGBO(80, 80, 80, 1.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )

                      // _buildStatusRow(request),
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
            color: Colors.blue,
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

