import 'package:flutter/material.dart';

class EsnaSpocScreen extends StatefulWidget {
  const EsnaSpocScreen({Key? key}) : super(key: key);

  @override
  State<EsnaSpocScreen> createState() => _EsnaSpocScreenState();
}

class _EsnaSpocScreenState extends State<EsnaSpocScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'Request Verification',
    'Monthly deduction',
    'Payment details',
    'RTO tax receipt',
  ];

  // You'll replace this with your actual data list
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
      'category': 'Request Verification',
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
      'category': 'Request Verification',
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
      'category': 'Monthly deduction',
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
      'category': 'Request Verification',
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
      'category': 'RTO tax receipt',
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
      'category': 'RTO tax receipt',

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
      'category': 'Monthly deduction',
    },
  ];

  // Filter requests based on selected tab category
  List<Map<String, dynamic>> get filteredRequests {
    return allRequests
        .where((request) => request['category'] == _tabs[_selectedTabIndex])
        .toList();
  }

  void _showModal(BuildContext context, Map<String, dynamic> request) {
    switch (_selectedTabIndex) {
      case 0:
        _showRequestVerificationModal(context, request);
        break;
      case 1:
        _showMonthlyDeductionModal(context, request);
        break;
      case 2:
        _showPaymentDetailsModal(context, request);
        break;
      case 3:
        _showRtoTaxReceiptModal(context, request);
        break;
    }
  }

  void _showRequestVerificationModal(
      BuildContext context, Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RequestVerificationModal(request: request),
    );
  }

  void _showMonthlyDeductionModal(
      BuildContext context, Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MonthlyDeductionModal(request: request),
    );
  }

  void _showPaymentDetailsModal(
      BuildContext context, Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentDetailsModal(request: request),
    );
  }

  void _showRtoTaxReceiptModal(
      BuildContext context, Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RtoTaxReceiptModal(request: request),
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
          // Selected Tab Header
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

          // Horizontal Scrollable Tab Bar
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
                          ? Colors.white
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE0E0E0)
                            : Colors.transparent,
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
                              ? Colors.black
                              : const Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Request Cards List
          Expanded(
            child: AnimatedSwitcher(
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
                  return _RequestCard(
                    request: filteredRequests[index],
                    onTap: () {
                      _showModal(context, filteredRequests[index]);
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

// Reusable Request Card Widget
class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onTap;

  const _RequestCard({
    required this.request,
    required this.onTap,
  });

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
                  request['requestId'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDetailRow('EMP ID', request['vehicleName'] ?? ''),
            const SizedBox(height: 8),
            _buildDetailRow('EMP name', request['dateOfRequest'] ?? ''),
            const SizedBox(height: 8),
            _buildDetailRow('Contact', request['contact'] ?? ''),
            const SizedBox(height: 8),
            _buildDetailRow('Date of request', request['dateOfRequest'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

// Modal 1: Request Verification
class _RequestVerificationModal extends StatelessWidget {
  final Map<String, dynamic> request;

  const _RequestVerificationModal({required this.request});

  @override
  Widget build(BuildContext context) {
    return _BaseModal(
      request: request,
      title: 'Request Verification',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Vehicle Type', request['vehicleName'] ?? ''),
          _buildDetailRow('Employee Name', request['employeeName'] ?? ''),
          _buildDetailRow('Employee ID', request['employeeId'] ?? ''),
          _buildDetailRow('Contact', request['contact'] ?? ''),
          _buildDetailRow('Date of Request', request['dateOfRequest'] ?? ''),
          _buildDetailRow('Status', request['status'] ?? ''),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Request Approved',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFF388E3B),
                          ),
                        ),
                        backgroundColor: Color(0xFFD7FFD8),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF59BF5C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
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
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Modal 2: Monthly Deduction
class _MonthlyDeductionModal extends StatelessWidget {
  final Map<String, dynamic> request;

  const _MonthlyDeductionModal({required this.request});

  @override
  Widget build(BuildContext context) {
    return _BaseModal(
      request: request,
      title: 'Monthly Deduction',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Employee Name', request['employeeName'] ?? ''),
          _buildDetailRow('Employee ID', request['employeeId'] ?? ''),
          _buildDetailRow('Base Amount', request['baseAmount'] ?? ''),
          _buildDetailRow('Cess Percentage', request['cessPercentage'] ?? ''),
          _buildDetailRow('Total', request['total'] ?? ''),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF59BF5C),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text(
                'Confirm Deduction',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Modal 3: Payment Details
class _PaymentDetailsModal extends StatelessWidget {
  final Map<String, dynamic> request;

  const _PaymentDetailsModal({required this.request});

  @override
  Widget build(BuildContext context) {
    return _BaseModal(
      request: request,
      title: 'Payment Details',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Eligibility', request['eligibility'] ?? ''),
          _buildDetailRow('Quotation', request['quotation'] ?? ''),
          _buildDetailRow('Corporate Registration', request['corporateRegistration'] ?? ''),
          _buildDetailRow('Total Amount', request['total'] ?? ''),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF59BF5C),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text(
                'Process Payment',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Modal 4: RTO Tax Receipt
class _RtoTaxReceiptModal extends StatelessWidget {
  final Map<String, dynamic> request;

  const _RtoTaxReceiptModal({required this.request});

  @override
  Widget build(BuildContext context) {
    return _BaseModal(
      request: request,
      title: 'RTO Tax Receipt',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Vehicle Type', request['vehicleName'] ?? ''),
          _buildDetailRow('Employee Name', request['employeeName'] ?? ''),
          _buildDetailRow('Cost Center', request['costCenter'] ?? ''),
          const SizedBox(height: 16),

          const Text(
            'Upload Receipt',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                style: BorderStyle.solid,
              ),
            ),
            child: const Column(
              children: [
                Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Click to upload receipt',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF59BF5C),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Base Modal Widget (DRY principle)
class _BaseModal extends StatelessWidget {
  final Map<String, dynamic> request;
  final String title;
  final Widget content;

  const _BaseModal({
    required this.request,
    required this.title,
    required this.content,
  });

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
                  horizontal: 16,
                  vertical: 16,
                ),
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
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
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
                      Row(
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
                            request['requestId'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      content,
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