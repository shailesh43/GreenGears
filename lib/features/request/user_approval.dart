import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UserApproval extends StatefulWidget {
  final int stage; // 23 for first approval, 25 for second approval
  final Map<String, dynamic> request;

  const UserApproval({
    super.key,
    required this.stage,
    required this.request,
  });

  @override
  State<UserApproval> createState() => _UserApprovalState();
}

class _UserApprovalState extends State<UserApproval> {
  final TextEditingController _commentsController = TextEditingController();


  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _showDeclarationModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _DeclarationModal(
          request: widget.request,
          onAccept: () {
            Navigator.pop(context); // Close modal
            _handleApproval();
          },
        );
      },
    );
  }

  void _handleApproval() {
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
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  void _handleRejection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Request Rejected',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFFD32F2F),
          ),
        ),
        backgroundColor: Color(0xFFFFCDD2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
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

  Widget _buildFirstApprovalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insurance Quote Approval',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 24),
        _buildDetailRow('EMP ID', widget.request['employeeId'] ?? '208829'),
        _buildDetailRow('Request ID', widget.request['requestId'] ?? 'CAR2025241'),
        _buildDetailRow('EMP name', widget.request['employeeName'] ?? 'Rahil Bopche'),
        _buildDetailRow('Grade', widget.request['grade'] ?? 'ME03'),
        _buildDetailRow('Eligibility (RS)', widget.request['eligibility'] ?? '50,000'),
        _buildDetailRow('Email', widget.request['email'] ?? 'rahil.bopche@tatapower.com'),
        _buildDetailRow('ESNA comments', widget.request['comments'] ?? 'Approved'),
        const SizedBox(height: 16),
        _buildDetailRow('Base insurance premium (in RS)', widget.request['basePremium'] ?? '36,460'),
        _buildDetailRow('Insurance Type', widget.request['insuranceType'] ?? 'Add on'),
        const SizedBox(height: 16),
        const _FileUploadField(label: 'Upload Document'),
        const SizedBox(height: 16),
        _FormTextField(
          label: 'Employee Comments',
          maxLines: 3,
          required: true,
          controller: _commentsController,
        ),
      ],
    );
  }

  Widget _buildSecondApprovalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Deduction',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 24),
        _buildDetailRow('EMP ID', widget.request['employeeId'] ?? '208829'),
        _buildDetailRow('Request ID', widget.request['requestId'] ?? 'CAR2025241'),
        _buildDetailRow('EMP name', widget.request['employeeName'] ?? 'Rahil Bopche'),
        _buildDetailRow('Grade', widget.request['grade'] ?? 'ME03'),
        _buildDetailRow('Eligibility (RS)', widget.request['eligibility'] ?? '50,000'),
        _buildDetailRow('Email', widget.request['email'] ?? 'rahil.bopche@tatapower.com'),
        _buildDetailRow('ESNA comments', widget.request['comments'] ?? 'Approved'),
        const SizedBox(height: 16),
        _buildDetailRow('Total EMI (in RS)', widget.request['totalEMI'] ?? '36,460'),
        _buildDetailRow('Car Allowance', widget.request['allowance'] ?? '13,500'),
        _buildDetailRow('Company Contribution (RS)', widget.request['contribution'] ?? '3800'),
        _buildDetailRow('EMI tenure (YRS)', widget.request['tenure'] ?? '3 years'),
        const SizedBox(height: 16),
        const _FileUploadField(label: 'Upload Document'),
        const SizedBox(height: 16),
        _FormTextField(
          label: 'Employee Comments',
          maxLines: 3,
          required: true,
          controller: _commentsController,
        ),
      ],
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
          'Approve/Reject',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            widget.stage == 23
                ? _buildFirstApprovalContent()
                : _buildSecondApprovalContent(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.stage == 25) {
                        _showDeclarationModal();
                      } else {
                        _handleApproval();
                      }
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
                    onPressed: _handleRejection,
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
      ),
    );
  }
}

// Reusable Widgets
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

class _DeclarationModal extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onAccept;

  const _DeclarationModal({
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
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
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
                            text: request['employeeName'] ?? 'Employee Name',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ', Employee Number '),
                          TextSpan(
                            text: request['employeeId'] ?? 'Employee code',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ', of '),
                          TextSpan(
                            text: request['company'] ?? 'Company Name',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' ('),
                          TextSpan(
                            text: request['workLocation'] ?? 'Work Location',
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
                            text: 'Under the said Car policy I am being provided with a car model Car Manufacturer, Car Model and colour (Vehicle/ Car) bearing Request Number ',
                          ),
                          TextSpan(
                            text: request['requestId'] ?? 'Request ID',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: ' pursuant there to, I hereby tender this undertaking cum indemnity bond.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.yellow[100],
                      child: const Text(
                        '*Registration Number will be allotted by the RTO on car registration once issued, and shall be appended in the said Indemnity bond in the place of Request Application Number, upon issuance.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'I agree and hereby irrevocably undertake that:',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildDeclarationPoints(),
                    const SizedBox(height: 16),
                    const Text(
                      'Further, I hereby authorize the Company to deduct any such amounts that shall remain unpaid by me within seven days of the demand made in respect thereof from any and all such monies, including salary, that may then or thereafter payable by the Company to me. Further, I undertake to indemnify the Company against any and all such losses which the Company may incur due to having provided me a Car under the Policy, including those listed above as a part of scheme.',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'I shall indemnify and compensate the Company if any fine, penalty, challan is issued for violation of Motor Vehicle Act or rules framed by competent authority, including and not limiting to challan for violating red light jump, dangerous driving, wrong parking etc.',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'I have read and understood the contents of the present undertaking and I agree with free consent without any force, coercion or duress, to abide by it.',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(
                              text: 'Thank You.\n\nYours Sincerely,\n\n'),
                          TextSpan(
                            text: '${request['employeeName'] ??
                                'Employee Name'},\n\n',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '${request['employeeId'] ??
                                'Employee code'},\n\n',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: 'Date: '),
                          TextSpan(
                            text: '$formattedDate,\n\n',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: 'Agreed.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(text: 'For '),
                          TextSpan(
                            text: '${request['company'] ?? 'Company Name'}\n\n',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: 'Authorised ES&A Spoc: '),
                          TextSpan(
                            text: '${request['assignedTo'] ?? 'SPOC Name'}\n\n',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: 'Dated: '),
                          TextSpan(
                            text: '$formattedDate\n\n',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: 'Agreed.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '*This is system generated document and requires NO Authorised Signature.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.yellow[100],
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

  List<Widget> _buildDeclarationPoints() {
    final points = [
      'Any other expenses, statutory or otherwise, not listed/applicable, as on date of issue of the Car policy dated 01st July 2022 relating to the Car shall be to my account, unless specifically approved by the Company. I also agree that any deduction of income tax as per the income tax law in force may be done by the Company.',

      'I shall use the vehicle for personal use, commuting to office and for official work only and the Vehicle shall not be put to any sort of commercial use. I understand that any breach of this covenant will lead to automatic withdrawal of this benefit by the Company and I shall be obliged to buy the Car from Company as per terms, condition of applicable Company Car Policy and that I shall exercise all such care and caution as a prudent person would as regards the use of the Vehicle while the same is in my possession.',

      'In the event I install any accessories in or upon the Vehicle in addition to that with which the Vehicle shall originally come equipped, the installation and the removal of the same shall be at my cost and expense. I also agree and undertake that in the event, any damage is caused to the Vehicle as a result of the additional accessories being installed or removed, I shall bear the expense of fully repairing the damage so caused. Further, in case the warranty of any such additional accessory/ies in or upon the Vehicle becomes void, in such case the Company shall not be responsible for the same and I shall solely bear the expense so caused.',

      'In the event the Vehicle is damaged on account of an accident/ 3rd party damage to Vehicle/ loss of Vehicle / any other damage to Vehicle or any injury to/ death of the user or third party after its possession was given to me by the Company and during the tenure the registration of car is not transferred in my name, the cost of repairing, loss for the damaged Car. 3rd Party damage, loss of vehicle or any other damage or any injury to/ death of the user or third party will first be subject to recovery on account of such damage, loss from the insurer. In the event the actual cost of repairing the damaged Car 3rd Party damage, loss of vehicle or any other damage or any injury to/ death of the user or third party is in excess of the amount recovered from the insurer, I agree to bear and pay the excess cost for such repairs.',

      'In the event the Vehicle is stolen (by way of theft) or Lost due to fire or any sort of damage caused to the Vehicle due to any form of natural calamity/ defect or any other problems with the quality of such Vehicle, the Company will have no responsibility or obligation whatsoever towards such theft or loss due to fire or damage or problems with the quality. Regardless to the above responsibility and obligation. Any Legal proceeding\'s/ monetary settlements caused due to Theft/Lost due to Fire or any damage caused to the Vehicle will be solely borne by me.',

      'In the event of any matter/ issue/ defect whatsoever arising out of or relating to such Vehicle in terms of monetary reparation or premium payment of the Vehicle, I shall be solely responsible for such matter/ issue/ defect and the Company shall not be liable or responsible for the same.',

      'I take the complete onus of being the only custodian of all the company owned car related original documents (Hard Copies) from the time of car being delivered to me in person. In the event of loss of any of Vehicle related documents viz., the Original Invoices, Debit Notes, RTO Tax Receipt, RC Smart Card or any other supporting documents, I shall be sole liable and responsible for such loss of documents.',

      'In event of any penalty/ fine imposed by the RTO/Traffic Police for over speeding, jumping the signal, etc. in relation to the traffic laws, I shall bear the sole responsibility for making payment towards such penalty/ fine personally and the Company will not be liable to pay any such penalty/ fine on my behalf.',

      'In any of the above circumstances or otherwise, I undertake that I shall not restrain or take any action against the Company towards the regular deduction of the lease rentals/EMI and other charges in full in accordance with its terms.',

      'In case of my promotion to the next higher grade, I shall continue to use the same Car until the tenure is over and the Company will maintain the Car as per my eligibility of higher Grade unless I purchase the Car by paying the remaining amount provided and get it transferred and registered in my name or in the name of third party (subject to written approval of the Company), as the case may be. In case of transfer of Car to third party is approved by Company, I shall carry out all the transfer formalities and all the cost towards the said transfer shall be solely borne by me.',

      'On completion of tenure, I will get the first preference to buy the Car at the agreed rate of the capitalized cost. The option to buy the Car has to be exercised by me within next one month from the date of completion of car tenure, by ensuring the Car is transferred and registered in my name or in the name of third party(subject to written approval of the Company), as the case may be. Sales Tax/duties/registration on transfer of Vehicle as applicable will be borne by me in case of third party transfer. I understand and agree that if I fail to get the Car transferred from the Company even after 03 months of the expiry date from date of completion of the said car tenure, the Company will be at liberty to dispose of the Car and no amount shall be payable to me from the proceeds of the sale and in addition to it the Company may initiate disciplinary action against me.',

      'In case I resign from the services of the Company for any reason whatsoever or retire, it shall be mandatory on me to buy the Car on payment of remaining amount, as maintained by Company.',

      'In case I apply for Sabbatical Leave or \'Break-In-Service\' (BIS) (for women Employee), it will be mandatory on me to buy the Car on payment of remaining amount, as maintained by Company. The option to buy the Car shall be exercised by me before leaving for BIS / Sabbatical. The Company will be at liberty to dispose off the Car and any loss /notional loss incurred in this transaction vis-à-vis the buyback price as above will be recovered from the full and final dues payable to me or otherwise.',

      'In case I am terminated for any reason whatsoever, the Company can forfeit my right to purchase the Car or impose such obligation(s) at its discretion.',

      'In case of my death within car tenure of joining the scheme, my legal heirs will be allowed to buy the Car at a price equivalent to remaining amount as maintained by Company. My heirs will only have option to buy the car either by settling directly the amount with the company or by getting it deducted from the F&F of the deceased, as per the discretion of the Company.',

      'The date on which the Car payment is disbursed to the Dealership, will be taken as the date on which I join the scheme. I can re-join the scheme only upon completion of car tenure after my first joining the scheme provided the earlier car has been purchased by me and is transferred and registered in my name or in the name of third party (subject to written approval of the Company), as the case may be. It will be sole discretion of the company to allow the transfer of Car to the third party.',

      'As provided in the foregoing paras, it is cleared to me and I undertake that until and unless I buy the Car and get it transferred and registered in my name or in the name of third party (subject to written approval of the Company), as the case may be, I shall not be entitled for allotment of new Car under the Car policy/scheme.',

      'The management of the Company may amend, alter, change, modify and substitute the scheme at any time at its sole discretion, prospectively and I will agree with the changes so done.',

      'In case of any differences in interpretation of the terms of the policy in vogue, the issue shall be referred to the Chief/ Head Administration, whose decision shall be final and binding on me.',
    ];

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