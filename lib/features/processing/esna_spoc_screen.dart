import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
      'category': 'Payment Details',
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
      'category': 'Payment details',
    },
  ];

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

// Reusable Form Widgets
class _FormTextField extends StatelessWidget {
  final String label;
  final bool required;
  final TextEditingController? controller;
  final int maxLines;

  const _FormTextField({
    required this.label,
    this.required = false,
    this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF757575),
                ),
              ),
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF59BF5C)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}


class _FileUploadField extends StatefulWidget {
  final String label;
  final bool acceptExcel;

  const _FileUploadField({
    required this.label,
    this.acceptExcel = false,
  });

  @override
  State<_FileUploadField> createState() => _FileUploadFieldState();
}

class _FileUploadFieldState extends State<_FileUploadField> {
  String? _fileName;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: widget.acceptExcel ? FileType.custom : FileType.any,
      allowedExtensions: widget.acceptExcel ? ['xlsx', 'xls'] : null,
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              children: [
                Icon(
                  _fileName == null ? Icons.cloud_upload_outlined : Icons.check_circle,
                  size: 32,
                  color: _fileName == null ? Colors.grey : const Color(0xFF59BF5C),
                ),
                const SizedBox(height: 8),
                Text(
                  _fileName ?? 'Click to upload',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: _fileName == null ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatefulWidget {
  final String label;

  const _DatePickerField({required this.label});

  @override
  State<_DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<_DatePickerField> {
  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate == null
                      ? 'Select date '
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: _selectedDate == null ? Colors.grey : Colors.black,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatefulWidget {
  final String label;
  final List<String> items;

  const _DropdownField({
    required this.label,
    required this.items,
  });

  @override
  State<_DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<_DropdownField> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6C6C6C),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          hint: const Text('Select document'),
          items: widget.items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedValue = newValue;
            });
          },
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
          _buildDetailRow('Employee Name', request['employeeName'] ?? 'Rahil Bopche'),
          _buildDetailRow('Employee ID', request['employeeId'] ?? '209164'),
          _buildDetailRow('Grade', request['grade'] ?? 'ME03'),
          _buildDetailRow('Manufactured by', request['manufacturedBy'] ?? 'Honda'),
          _buildDetailRow('Vehicle Type', request['vehicleType'] ?? 'Diesel'),
          _buildDetailRow('Vehicle Model', request['vehicleModel'] ?? 'fourseater'),
          _buildDetailRow('Email', request['email'] ?? ''),
          _buildDetailRow('Color', request['color'] ?? 'white'),
          _buildDetailRow('Comments by Employee', request['comments'] ?? 'String'),
          const SizedBox(height: 24),

          const _FormTextField(label: 'ES&A Comments', maxLines: 3, required: true,),
          const SizedBox(height: 16),
          const _FileUploadField(label: 'Upload Document'),
          const SizedBox(height: 16),
          _DropdownField(
            label: 'View Document',
            items: ['Document 1', 'Document 2', 'Document 3'],
          ),
          const SizedBox(height: 24),

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

/// Modal 2: Monthly Deduction
class _MonthlyDeductionModal extends StatefulWidget {
  final Map<String, dynamic> request;

  const _MonthlyDeductionModal({required this.request});

  @override
  State<_MonthlyDeductionModal> createState() => _MonthlyDeductionModalState();
}

class _MonthlyDeductionModalState extends State<_MonthlyDeductionModal> {
  String? _total;
  String? _carAllowance;
  String? _companyContribution;
  String? _emiTenure;
  String? _monthlyEmi;
  bool _excelUploaded = false;

  Future<void> _downloadExcelTemplate() async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Storage permission denied'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }
      }

      // Load the Excel file from assets
      final ByteData data = await rootBundle.load('assets/docs/EMI_Calculator.xlsx');
      final List<int> bytes = data.buffer.asUint8List();

      // Get the Downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not find download directory');
      }

      // Create the file path
      final String filePath = '${directory.path}/EMI_Calculator.xlsx';
      final File file = File(filePath);

      // Write the file
      await file.writeAsBytes(bytes);

      // Show success message with file path
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Download format excel at $filePath',
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF388E3B),
              ),
            ),
            backgroundColor: const Color(0xFFD7FFD8),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading template: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleExcelUpload() {
    // Simulate excel data extraction
    setState(() {
      _excelUploaded = true;
      _total = '₹ 10,00,000';
      _carAllowance = '₹ 40,000';
      _companyContribution = '₹ 60,000';
      _emiTenure = '5 years';
      _monthlyEmi = '₹ 16,667';
    });
  }

  @override
  Widget build(BuildContext context) {
    return _BaseModal(
      request: widget.request,
      title: 'Monthly Deduction',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "1. Download and fill the cells",
            style: TextStyle(
              color: Color.fromRGBO(108, 108, 108, 1.0),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _downloadExcelTemplate,
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Download Excel Template'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF585858),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          _ExcelFileUploadField(
            label: '2. Upload Excel',
            onFileSelected: _handleExcelUpload,
          ),
          const SizedBox(height: 24),

          if (_excelUploaded) ...[
            const Text(
              'Extracted Data',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Total', _total ?? ''),
            _buildDetailRow('Car Allowance', _carAllowance ?? ''),
            _buildDetailRow('Company Contribution', _companyContribution ?? ''),
            _buildDetailRow('EMI Tenure in Years', _emiTenure ?? ''),
            _buildDetailRow('Monthly EMI', _monthlyEmi ?? ''),
            const SizedBox(height: 24),
          ],

          const _FormTextField(label: 'ES&A Comments', maxLines: 3),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Monthly Deduction Saved',
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
                    backgroundColor: const Color(0xFF62CA66),
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
// Excel File Upload Widget
class _ExcelFileUploadField extends StatefulWidget {
  final String label;
  final VoidCallback onFileSelected;

  const _ExcelFileUploadField({
    required this.label,
    required this.onFileSelected,
  });

  @override
  State<_ExcelFileUploadField> createState() => _ExcelFileUploadFieldState();
}

class _ExcelFileUploadFieldState extends State<_ExcelFileUploadField> {
  String? _fileName;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
      widget.onFileSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              children: [
                Icon(
                  _fileName == null ? Icons.cloud_upload_outlined : Icons.check_circle,
                  size: 32,
                  color: _fileName == null ? Colors.grey : const Color(0xFF59BF5C),
                ),
                const SizedBox(height: 8),
                Text(
                  _fileName ?? 'Click to upload Excel',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: _fileName == null ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Modal 3: Payment Details
class _PaymentDetailsModal extends StatelessWidget {
  final Map<String, dynamic> request;

  const _PaymentDetailsModal({required this.request});
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

  @override
  Widget build(BuildContext context) {
    return _BaseModal(
      request: request,
      title: 'Payment Details',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('EMP ID', request['employeeId'] ?? '208829'),
          const SizedBox(height: 8),
          _buildDetailRow('Request ID', request['requestId'] ?? 'CAR2025241'),
          const SizedBox(height: 8),
          _buildDetailRow('EMP name', request['employeeName'] ?? 'Rahil Bopche'),
          const SizedBox(height: 8),
          _buildDetailRow('Grade', request['grade'] ?? 'ME03'),
          const SizedBox(height: 8),
          _buildDetailRow('Eligibility (RS)', request['eligibility'] ?? '50,000'),
          const SizedBox(height: 8),
          _buildDetailRow('EMI approval comments', request['comments'] ?? 'Approved'),
          const SizedBox(height: 16),

          const _FormTextField(label: 'PO Number', required: true,),
          const SizedBox(height: 16),
          const _DatePickerField(label: 'PO Date'),
          const SizedBox(height: 16),
          const _FormTextField(label: 'Disbursement Amount', required: true,),
          const SizedBox(height: 16),
          const _DatePickerField(label: 'Payment Date'),
          const SizedBox(height: 16),
          const _FormTextField(label: 'UTR', required: true,),
          const SizedBox(height: 16),
          const _FileUploadField(label: 'Upload Document'),
          const SizedBox(height: 16),
          const _FormTextField(label: 'Comments', maxLines: 3, required: true,),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Payment Details Saved',
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
                    'reject',
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
}

// Modal 4: RTO Tax Receipt
class _RtoTaxReceiptModal extends StatelessWidget {
  final Map<String, dynamic> request;

  const _RtoTaxReceiptModal({required this.request});

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

  @override
  Widget build(BuildContext context) {
    return _BaseModal(
      request: request,
      title: 'RTO Tax Receipt',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Request ID', request['request ID'] ?? 'CAR2025241'),
          const SizedBox(height: 8),
          _buildDetailRow('EMP ID', request['employeeId'] ?? '208277'),
          const SizedBox(height: 8),
          _buildDetailRow('EMP name', request['employeeName'] ?? 'Rahil Bopche'),
          const SizedBox(height: 8),
          _buildDetailRow('Vehicle model', request['vehiclemodell'] ?? 'Kia Sonet G1.2 MT Gravity'),
          const SizedBox(height: 8),
          const _FormTextField(label: 'Vehicle Number', required: true,),
          const SizedBox(height: 8),
          const _FormTextField(label: 'Chassis Number', required: true,),
          const SizedBox(height: 16),
          const _FormTextField(label: 'Engine Number', required: true,),
          const SizedBox(height: 16),
          const _FormTextField(label: 'Fastag Number', required: true,),
          const SizedBox(height: 16),
          const _DatePickerField(label: 'Vehicle Handover Date'),
          const SizedBox(height: 16),
          const _FileUploadField(label: 'Upload Files'),
          const SizedBox(height: 16),
          _DropdownField(
            label: 'View Document',
            items: ['RTO Certificate', 'Tax Receipt', 'Insurance Copy'],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'RTO Details Submitted',
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
}

// Base Modal Template
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}