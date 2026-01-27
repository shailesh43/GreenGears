import 'package:flutter/material.dart';

// Custom
import '../widgets/form_detail_row.dart';
import '../../network/api_models/car_request.dart';

class RequestCard extends StatelessWidget {
  // final Map<String, dynamic> request;
  final CarRequest request;
  final VoidCallback onTap;

  const RequestCard({
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
                  request.requestId.toString() ?? '',
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

            DetailRow(label: 'Vehicle Name', value: request.carModel?.toString() ?? ''),
            DetailRow(label: 'EMP ID', value: request.empId?.toString() ?? ''),
            DetailRow(label: 'EMP Name', value: request.employeeName.toString() ?? ''),
            DetailRow(
              label: 'Contact',
              value: request.contact?.toString() ?? '',
            ),
          ],
        ),
      ),
    );
  }
}
