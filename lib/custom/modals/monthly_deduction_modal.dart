import 'package:flutter/material.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../network/api_models/car_request.dart';

//Customs
import '../widgets/form_detail_row.dart';
import '../widgets/excel_file_upload_field.dart';
import '../widgets/form_text_field.dart';
import '../widgets/action_button_pair.dart';
import './base_modal.dart';

class MonthlyDeductionModal extends StatefulWidget {
  final CarRequest request;

  const MonthlyDeductionModal({
    super.key,
    required this.request
  });

  @override
  State<MonthlyDeductionModal> createState() => _MonthlyDeductionModalState();
}

class _MonthlyDeductionModalState extends State<MonthlyDeductionModal> {
  String? _total;
  String? _carAllowance;
  String? _companyContribution;
  String? _emiTenure;
  String? _monthlyEmi;
  bool _excelUploaded = false;

  Future<void> _downloadExcelTemplate() async {
    try {
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

  // Dummy data as of now
  void _handleExcelUpload() {
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
    return BaseModal(
      request: widget.request,
      title: 'Monthly Deduction',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "1. Download and fill the EMI Calculator excel",
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

          ExcelFileUploadField(
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
            DetailRow(label: 'Total', value: _total ?? ''),
            DetailRow(label: 'Car Allowance', value: _carAllowance ?? ''),
            DetailRow(label: 'Company Contribution', value: _companyContribution ?? ''),
            DetailRow(label: 'EMI Tenure in Years', value: _emiTenure ?? ''),
            DetailRow(label: 'Monthly EMI', value: _monthlyEmi ?? ''),
            const SizedBox(height: 24),
          ],

          const FormTextField(label: 'ES&A Comments', maxLines: 3),
          const SizedBox(height: 24),

          ActionButtonPair(
            primaryText: 'Approve',
            secondaryText: 'Reject',
            primaryMessage: 'Request Approved',
            secondaryMessage: 'Request Rejected',
            onPrimaryAction: () {
              // Handle approve logic
            },
            onSecondaryAction: () {
              // Handle reject logic
            },
          ),
        ],
      ),
    );
  }
}