import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import '../../network/api_models/car_request.dart';

class DeclarationAcceptanceModal extends StatelessWidget {
  final CarRequest request;
  final VoidCallback onAccept;

  DeclarationAcceptanceModal({
    super.key,
    required this.request,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();
    final formattedDate = '${currentDate.day.toString().padLeft(
        2, '0')}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate
        .year}';

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Declaration Acceptance',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      // Print/Download Declaration Button
                      IconButton(
                        icon: const Icon(
                          Icons.download,
                          color: Color(0xF5323232),
                        ),
                        tooltip: 'Download Declaration',
                        onPressed: () => _downloadDeclaration(context, formattedDate),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'To Whom So Ever It May Concern.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sub.: Indemnity Bond / Undertaking for participation in the Official Car & Related Benefits Policy/Scheme.',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(text: 'I, '),
                          TextSpan(
                            text: request.employeeName ?? 'Employee Name',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ', Employee Number '),
                          TextSpan(
                            text: request.empId ?? 'Employee code',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ', of '),
                          TextSpan(
                            text: request.company ?? 'Company Name',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' ('),
                          TextSpan(
                            text: request.workLocation ?? 'Work Location',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: ') availed the option under the Car & Related Benefits Policy, effectively dated and put into implementation on/after 01st July 2022 (the "Policy" Ref: Document No: Tata Power - CHRO-HR-CRB), as amended from time to time.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Under the said Car policy I am being provided with a car model ',
                          ),
                          TextSpan(
                            text: '${request.manufacturer ?? 'Manufacturer'}, ${request.carModel ?? 'Model'} and ${request.colorChoice ?? 'Color'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: ' (Vehicle/ Car) bearing Request Number ',
                          ),
                          TextSpan(
                            text: request.requestId ?? 'Request ID',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: ', at an agreed capitalized cost of Rs. ',
                          ),
                          TextSpan(
                            text: request.quotation?.toStringAsFixed(2) ?? '0.00',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: ' (Rupees in words) including GST @ ',
                          ),
                          const TextSpan(
                            text: 'XX%',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: ' and other incidental charges of Rs. ',
                          ),
                          const TextSpan(
                            text: 'XXXX',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: ', for a period of ',
                          ),
                          TextSpan(
                            text: '${request.completeEmiTenure ?? 'XX'} months',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: ' commencing from the date of disbursement of car payment to dealership.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'I hereby agree and undertake to do and observe the following:',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildDeclarationPoints(),
                    const SizedBox(height: 24),
                    const Text(
                      'Yours sincerely,',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Name: ${request.employeeName ?? 'Employee Name'}',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                    ),
                    Text(
                      'Emp. No: ${request.empId ?? 'Employee code'}',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                    ),
                    Text(
                      'Date: $formattedDate',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFD700)),
                      ),
                      child: const Text(
                        '**This Document needs to be signed in Original, with your ES&A SPOC, along with the Stamp Paper. Connect with your local ES&A SPOC for the same. This is a Legal binding & is mandatory in nature.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
              child: ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF59BF5C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  'I Accept',
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
      ),
    );
  }

  // Download and Open Declaration - Using open_filex
  Future<void> _downloadDeclaration(BuildContext context, String formattedDate) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF59BF5C),
            ),
          );
        },
      );

      final pdf = pw.Document();
      final points = _getDeclarationPointsText();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Header
              pw.Center(
                child: pw.Text(
                  'To Whom So Ever It May Concern.',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),

              // Subject
              pw.Text(
                'Sub.: Indemnity Bond / Undertaking for participation in the Official Car & Related Benefits Policy/Scheme.',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 16),

              // Employee Details Paragraph
              pw.Paragraph(
                text: 'I, ${request.employeeName ?? 'Employee Name'}, Employee Number ${request.empId ?? 'Employee code'}, of ${request.company ?? 'Company Name'} (${request.workLocation ?? 'Work Location'}) availed the option under the Car & Related Benefits Policy, effectively dated and put into implementation on/after 01st July 2022 (the "Policy" Ref: Document No: Tata Power - CHRO-HR-CRB), as amended from time to time.',
                style: const pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 16),

              // Car Details Paragraph
              pw.Paragraph(
                text: 'Under the said Car policy I am being provided with a car model ${request.manufacturer ?? 'Manufacturer'}, ${request.carModel ?? 'Model'} and ${request.colorChoice ?? 'Color'} (Vehicle/ Car) bearing Request Number ${request.requestId ?? 'Request ID'}, at an agreed capitalized cost of Rs. ${request.quotation?.toStringAsFixed(2) ?? '0.00'}',
                style: const pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 16),

              // Declaration Points Header
              pw.Text(
                'I hereby agree and undertake to do and observe the following:',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              // Declaration Points
              ...points.asMap().entries.map((entry) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        width: 25,
                        child: pw.Text(
                          '${entry.key + 1}.',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          entry.value,
                          style: const pw.TextStyle(fontSize: 11),
                          textAlign: pw.TextAlign.justify,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              pw.SizedBox(height: 24),

              // Signature Section
              pw.Text(
                'Yours sincerely,',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Name: ${request.employeeName ?? 'Employee Name'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Emp. No: ${request.empId ?? 'Employee code'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Date: $formattedDate',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                'Signature: _____________________',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 24),

              // Footer Note
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.orange),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  '**This Document needs to be signed in Original, with your ES&A SPOC, along with the Stamp Paper. Connect with your local ES&A SPOC for the same. This is a Legal binding & is mandatory in nature.',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      // Save PDF to device
      final output = await getApplicationDocumentsDirectory();
      final fileName = 'Declaration_${request.empId}_$formattedDate.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Open the PDF file with open_filex
      final result = await OpenFilex.open(file.path);

      // Show success message
      if (context.mounted) {
        String message;
        if (result.type == ResultType.done) {
          message = 'Declaration saved and opened successfully';
        } else if (result.type == ResultType.noAppToOpen) {
          message = 'Declaration saved to: ${file.path}\nNo PDF viewer app found';
        } else {
          message = 'Declaration saved to: ${file.path}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: result.type == ResultType.done
                ? const Color(0xFF59BF5C)
                : Colors.orange,
            duration: const Duration(seconds: 4),
            action: result.type == ResultType.noAppToOpen
                ? SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            )
                : null,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (context.mounted) {
        Navigator.pop(context);
      }

      debugPrint('Error generating declaration: $e');

      // Show error to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate declaration: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  List<String> _getDeclarationPointsText() {
    return [
      'Any other expenses, statutory or otherwise, not listed/applicable, as on date of issue of the Car policy dated 01st July 2022 relating to the Car shall be to my account, unless specifically approved by the Company. I also agree that any deduction of income tax as per the income tax law in force may be done by the Company.',

      'I shall use the vehicle for personal use, commuting to office and for official work only and the Vehicle shall not be put to any sort of commercial use. I understand that any breach of this covenant will lead to automatic withdrawal of this benefit by the Company and I shall be obliged to buy the Car from Company as per terms, condition of applicable Company Car Policy and that I shall exercise all such care and caution as a prudent person would as regards the use of the Vehicle while the same is in my possession.',

      'In the event I install any accessories in or upon the Vehicle in addition to that with which the Vehicle shall originally come equipped, the installation and the removal of the same shall be at my cost and expense. I also agree and undertake that in the event, any damage is caused to the Vehicle as a result of the additional accessories being installed or removed, I shall bear the expense of fully repairing the damage so caused. Further, in case the warranty of any such additional accessory/ies in or upon the Vehicle becomes void, in such case the Company shall not be responsible for the same and I shall solely bear the expense so caused.',

      'In the event the Vehicle is damaged on account of an accident/ 3rd party damage to Vehicle/ loss of Vehicle / any other damage to Vehicle or any injury to/ death of the user or third party after its possession was given to me by the Company and during the tenure the registration of car is not transferred in my name, the cost of repairing, loss for the damaged Car. 3rd Party damage, loss of vehicle or any other damage or any injury to/ death of the user or third party will first be subject to recovery on account of such damage, loss from the insurer. In the event the actual cost of repairing the damaged Car 3rd Party damage, loss of vehicle or any other damage or any injury to/ death of the user or third party is in excess of the amount recovered from the insurer, I agree to bear and pay the excess cost for such repairs.',

      'In the event the Vehicle is stolen (by way of theft) or Lost due to fire or any sort of damage caused to the Vehicle due to any form of natural calamity/ defect or any other problems with the quality of such Vehicle, the Company will have no responsibility or obligation whatsoever towards such theft or loss due to fire or damage or problems with the quality. Regardless to the above responsibility and obligation. Any Legal proceedings/ monetary settlements caused due to Theft/Lost due to Fire or any damage caused to the Vehicle will be solely borne by me.',

      'In the event of any matter/ issue/ defect whatsoever arising out of or relating to such Vehicle in terms of monetary reparation or premium payment of the Vehicle, I shall be solely responsible for such matter/ issue/ defect and the Company shall not be liable or responsible for the same.',

      'I take the complete onus of being the only custodian of all the company owned car related original documents (Hard Copies) from the time of car being delivered to me in person. In the event of loss of any of Vehicle related documents viz., the Original Invoices, Debit Notes, RTO Tax Receipt, RC Smart Card or any other supporting documents, I shall be sole liable and responsible for such loss of documents.',

      'In event of any penalty/ fine imposed by the RTO/Traffic Police for over speeding, jumping the signal, etc. in relation to the traffic laws, I shall bear the sole responsibility for making payment towards such penalty/ fine personally and the Company will not be liable to pay any such penalty/ fine on my behalf.',

      'In any of the above circumstances or otherwise, I undertake that I shall not restrain or take any action against the Company towards the regular deduction of the lease rentals/EMI and other charges in full in accordance with its terms.',

      'In case of my promotion to the next higher grade, I shall continue to use the same Car until the tenure is over and the Company will maintain the Car as per my eligibility of higher Grade unless I purchase the Car by paying the remaining amount provided and get it transferred and registered in my name or in the name of third party (subject to written approval of the Company), as the case may be. In case of transfer of Car to third party is approved by Company, I shall carry out all the transfer formalities and all the cost towards the said transfer shall be solely borne by me.',

      'On completion of tenure, I will get the first preference to buy the Car at the agreed rate of the capitalized cost. The option to buy the Car has to be exercised by me within next one month from the date of completion of car tenure, by ensuring the Car is transferred and registered in my name or in the name of third party(subject to written approval of the Company), as the case may be. Sales Tax/duties/registration on transfer of Vehicle as applicable will be borne by me in case of third party transfer. I understand and agree that if I fail to get the Car transferred from the Company even after 03 months of the expiry date from date of completion of the said car tenure, the Company will be at liberty to dispose of the Car and no amount shall be payable to me from the proceeds of the sale and in addition to it the Company may initiate disciplinary action against me.',

      'In case I resign from the services of the Company for any reason whatsoever or retire, it shall be mandatory on me to buy the Car on payment of remaining amount, as maintained by Company.',

      'In case I apply for Sabbatical Leave or Break-In-Service (BIS) (for women Employee), it will be mandatory on me to buy the Car on payment of remaining amount, as maintained by Company. The option to buy the Car shall be exercised by me before leaving for BIS / Sabbatical. The Company will be at liberty to dispose off the Car and any loss /notional loss incurred in this transaction vis-a-vis the buyback price as above will be recovered from the full and final dues payable to me or otherwise.',

      'In case I am terminated for any reason whatsoever, the Company can forfeit my right to purchase the Car or impose such obligation(s) at its discretion.',

      'In case of my death within car tenure of joining the scheme, my legal heirs will be allowed to buy the Car at a price equivalent to remaining amount as maintained by Company. My heirs will only have option to buy the car either by settling directly the amount with the company or by getting it deducted from the F&F of the deceased, as per the discretion of the Company.',

      'The date on which the Car payment is disbursed to the Dealership, will be taken as the date on which I join the scheme. I can re-join the scheme only upon completion of car tenure after my first joining the scheme provided the earlier car has been purchased by me and is transferred and registered in my name or in the name of third party (subject to written approval of the Company), as the case may be. It will be sole discretion of the company to allow the transfer of Car to the third party.',

      'As provided in the foregoing paras, it is cleared to me and I undertake that until and unless I buy the Car and get it transferred and registered in my name or in the name of third party (subject to written approval of the Company), as the case may be, I shall not be entitled for allotment of new Car under the Car policy/scheme.',

      'The management of the Company may amend, alter, change, modify and substitute the scheme at any time at its sole discretion, prospectively and I will agree with the changes so done.',

      'In case of any differences in interpretation of the terms of the policy in vogue, the issue shall be referred to the Chief/ Head Administration, whose decision shall be final and binding on me.',
    ];
  }

  List<Widget> _buildDeclarationPoints() {
    final points = _getDeclarationPointsText();

    return points
        .asMap()
        .entries
        .map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.key + 1}. ',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
              ),
            ),
            Expanded(
              child: Text(
                entry.value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
