import 'package:flutter/material.dart';

class SearchRequestResult extends StatelessWidget {
  final String requestId;
  final String vehicleName;
  final String employeeName;
  final String employeeId;
  final String phone;
  final String dateOfRequest;
  final String company;
  final String address;
  final String cluster;
  final String grade;
  final String costCenter;
  final String eligibility;
  final String baseAmount;
  final String cessPercentage;
  final String corporateRegistration;
  final String quotation;
  final String total;
  final String status;

  const SearchRequestResult({
    Key? key,
    required this.requestId,
    required this.vehicleName,
    required this.employeeName,
    required this.employeeId,
    required this.phone,
    required this.dateOfRequest,
    required this.company,
    required this.address,
    required this.cluster,
    required this.grade,
    required this.costCenter,
    required this.eligibility,
    required this.baseAmount,
    required this.cessPercentage,
    required this.corporateRegistration,
    required this.quotation,
    required this.total,
    required this.status,
  }) : super(key: key);

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
        title: Text(
          employeeName,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildDetailRow('Vehicle Name', vehicleName),
            _buildDetailRow('Employee Name', employeeName),
            _buildDetailRow('Employee ID', employeeId),
            _buildDetailRow('Phone', phone),
            _buildDetailRow('Date of Request', dateOfRequest),
            _buildDetailRow('Company', company),
            _buildDetailRow('Address', address, isMultiline: true),
            const SizedBox(height: 8),
            _buildDetailRow('Cluster', cluster, isMultiline: true),
            _buildDetailRow('Grade', grade),
            _buildDetailRow('Cost center', costCenter),
            _buildDetailRow('Eligibility', eligibility),
            _buildDetailRow('Cost center', costCenter),
            const Divider(height: 1,),
            const SizedBox(height: 8),
            _buildDetailRow('Base Amount', baseAmount, isBold: true),
            _buildDetailRow('CESS percentage', cessPercentage),
            _buildDetailRow('Corporate Registration Amount', corporateRegistration),
            _buildDetailRow('Quotation Amount', quotation),
            const SizedBox(height: 16),
            _buildTotalRow(),
            const SizedBox(height: 24),
            _buildStatusRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          requestId,
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

  Widget _buildTotalRow() {
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
          total,
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

  Widget _buildStatusRow() {
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
          status,
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

// Example usage:
// SearchRequestResult(
//   requestId: 'CAR2025242',
//   vehicleName: 'RE Guerilla',
//   employeeName: 'Rahil Bopche',
//   employeeId: '209164',
//   phone: '+84549721',
//   dateOfRequest: '01/11/2019',
//   company: 'The Tata Power Co. Ltd.',
//   address: 'Technopolis Knowledge Park\n4th floor, Andheri (E),\nMumbai 400093',
//   cluster: 'The Tata Power Co. Ltd.\nCorporate functions\n& International',
//   grade: 'ME03',
//   costCenter: '1900022041',
//   eligibility: '₹ 4300.50',
//   baseAmount: '₹ 40, 500',
//   cessPercentage: '10 %',
//   corporateRegistration: '₹ 2000',
//   quotation: '5 %',
//   total: '₹ 10,00, 000',
//   status: 'Requested to ES&A',
// )