import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';


class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: Policy(),
        debugShowCheckedModeBanner: false
    );
  }
}

class Policy extends StatefulWidget {
  const Policy({super.key});

  @override
  State<Policy> createState() => _Policy();
}

class _Policy extends State<Policy> {
  String _selectedSection = 'All Sections';
  final List<String> _sections = [
    'All Sections',
    'Objective',
    'Scope & Applicability',
    'Car Schemes',
    'Eligibility',
    'Reimbursement Process',
    'General Guidelines'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Car & Related Benefits Policy',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
          shape: CircleBorder(),
        onPressed: () async {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Downloading policy ...'),
                backgroundColor: Color.fromRGBO(117, 117, 117, 1),
              ),
            );

            // Load PDF from assets
            final byteData = await rootBundle.load('assets/docs/CarPolicy.pdf');

            // Get device directory
            final directory = await getApplicationDocumentsDirectory();

            final file = File('${directory.path}/CarPolicy.pdf');

            // Write file
            await file.writeAsBytes(
              byteData.buffer.asUint8List(
                byteData.offsetInBytes,
                byteData.lengthInBytes,
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                // content: Text('Policy downloaded to ${file.path}'),
                content: Text('Policy downloaded to your files'),
                backgroundColor: Color.fromRGBO(98, 202, 102, 1.0),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error downloading policy: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },

        backgroundColor: const Color.fromRGBO(255, 255, 255, 1.0),
        child: const Icon(Icons.download, color: Color.fromRGBO(80, 80, 80, 1.0)),


      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Filter Dropdown

            // Policy Version Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(243, 244, 246, 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, size: 20, color: Color.fromRGBO(75, 85, 99, 1)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Version 1.3 | Effective from: 1st July 2022',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromRGBO(75, 85, 99, 1),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 1. OBJECTIVE
            _buildSectionHeader('1. OBJECTIVE'),
            _buildContentText(
                'The policy provides guidelines on purchase and usage of company-provided cars to address travel needs of officers, ensuring efficient use of time and productivity. It covers eligibilities, procedures, and guidelines governing Car & Related Benefits.'
            ),
            const SizedBox(height: 20),

            // 2. SCOPE & APPLICABILITY
            _buildSectionHeader('2. SCOPE & APPLICABILITY'),
            _buildContentText(
                'This policy applies to all officers in Management cadre (Work Level/Grade WL MA, MB, MC, MD and ME01 to ME04A) on permanent rolls of Tata Power and associated companies including CGPL, MPL, IEL, TPTCL, PTL, TPSSL, TPADL, TPREL, WREL, TPRML, TPCODL, TPSODL, TPWODL, TPNODL.'
            ),
            const SizedBox(height: 20),

            // 3. CAR SCHEMES
            _buildSectionHeader('3. COMPANY ALLOTTED CAR SCHEMES'),
            _buildSubSection('3a. Car Scheme through Leasing Partner'),
            _buildBulletPoint('Employees with existing leasing arrangements continue under that scheme until completion'),
            _buildBulletPoint('Officer responsible for car maintenance during lease period'),
            _buildBulletPoint('Minimum lease tenure: 5 years (full year blocks)'),
            const SizedBox(height: 12),

            _buildSubSection('3b. Car Scheme through Company (Direct Purchase)'),
            _buildBulletPoint('Company purchases and allots car to eligible officers'),
            _buildBulletPoint('Company bears Ex-showroom price, RTO taxes, registration, and insurance up to eligibility limit'),
            _buildBulletPoint('EMI tenure: 5 years (deducted from salary)'),
            _buildBulletPoint('Officers with less than 12 months before superannuation are not eligible'),
            const SizedBox(height: 20),

            // 4. ELIGIBILITY
            _buildSectionHeader('4. ELIGIBILITY'),
            _buildEligibilityTable(),
            const SizedBox(height: 12),
            _buildContentText(
                '• Officers may opt for higher value cars; excess EMI borne by employee from flexi allowance\n'
                    '• WL MD & above can opt for cars less than eligibility\n'
                    '• Reimbursements for maintenance, fuel, and driver claimed via bills/receipts within same FY'
            ),
            const SizedBox(height: 16),

            _buildSubSection('Top-up Reimbursement (from Flexi Allowance)'),
            _buildTopUpTable(),
            const SizedBox(height: 20),

            // 5. PROCESS FOR AVAILING CAR
            _buildSectionHeader('5. PROCESS FOR AVAILING COMPANY ALLOCATED CAR'),
            _buildNumberedPoint('i)', 'Submit vehicle requisition application to divisional ES&A team'),
            _buildNumberedPoint('ii)', 'Select vehicle and obtain quotations from registered dealers'),
            _buildNumberedPoint('iii)', 'ES&A provides EMI details; process begins after officer consent'),
            _buildNumberedPoint('iv)', 'On delivery, EMI/lease rental deduction starts from monthly salary'),
            _buildNumberedPoint('v)', 'Officers can allocate Maintenance, Fuel, and Driver expenses from Flexi Allowance'),
            const SizedBox(height: 20),

            // 6. REIMBURSEMENT PROCESS
            _buildSectionHeader('6. REIMBURSEMENT PROCESS'),
            _buildBulletPoint('Submit receipts through Employee Self Service (ESS) portal'),
            _buildBulletPoint('Fuel & Maintenance: Submit actual expense receipts'),
            _buildBulletPoint('Driver expenses: Upload Personal Driver Undertaking'),
            _buildBulletPoint('WL MC & above may avail Petro Card facility for fuel'),
            _buildBulletPoint('Officers not claiming expenses receive eligible amount in salary after tax deduction'),
            const SizedBox(height: 20),

            // 7. SCENARIOS & BUYBACK
            _buildSectionHeader('7. SCENARIOS INCLUDING BUYBACK'),

            _buildScenarioCard(
              'Buyback',
              'After completion of 5 years, officer must buy back car at 10% of capitalized/written down value. Company purchase scheme allows 2-year extension with continued reimbursements.',
              Icons.shopping_cart_outlined,
            ),
            const SizedBox(height: 12),

            _buildScenarioCard(
              'Transfer within Tata Power Group',
              'Officer may continue with same car. Shifting and transfer expenses borne by company as per existing provisions.',
              Icons.swap_horiz,
            ),
            const SizedBox(height: 12),

            _buildScenarioCard(
              'Transfer/Separation',
              'For transfer to other Tata Group companies or resignation/termination, officer must buy back car at foreclosure value.',
              Icons.exit_to_app,
            ),
            const SizedBox(height: 12),

            _buildScenarioCard(
              'Superannuation/Retirement',
              'Officer must settle account within 2 months of superannuation. For company purchase scheme, EMI applicable up to 3 months prior to retirement.',
              Icons.work_off_outlined,
            ),
            const SizedBox(height: 20),

            // 8. GENERAL GUIDELINES
            _buildSectionHeader('8. GENERAL GUIDELINES'),
            _buildBulletPoint('Car remains allotted for full lease period regardless of grade change on promotion'),
            _buildBulletPoint('Officers with existing Car Loan must settle before availing company scheme'),
            _buildBulletPoint('Officers in current scheme continue under same terms until completion'),
            _buildBulletPoint('All tax implications borne by the officer'),
            _buildBulletPoint('Officer responsible for settling outstanding dues during transfer/separation'),
            _buildBulletPoint('Upon EMI completion, mandatory buyback as per applicable norms'),
            const SizedBox(height: 20),

            // 9. OFFICERS NOT OPTING CAR SCHEME
            _buildSectionHeader('9. OFFICERS NOT OPTING COMPANY CAR SCHEME'),
            _buildContentText(
                'a) Eligible to claim intra-city travel expenses as per Travel Policy\n'
                    'b) Personal car owners can avail reimbursement for maintenance, fuel, and driver as per Income Tax rules\n'
                    'c) Appropriate declarations required to claim IT benefits'
            ),
            const SizedBox(height: 20),

            // 10. ROLES & RESPONSIBILITIES
            _buildSectionHeader('10. ROLES & RESPONSIBILITIES'),
            _buildResponsibilityCard('Officers', [
              'Select vehicle and obtain quotations',
              'Submit application forms to ES&A',
              'Submit valid bills/receipts for reimbursements via ESS portal',
            ]),
            const SizedBox(height: 12),
            _buildResponsibilityCard('ES&A Team', [
              'Place car orders for officers',
              'Inform Payroll Team about EMI/lease rental deductions',
              'Maintain central database of all car allocations',
            ]),
            const SizedBox(height: 12),
            _buildResponsibilityCard('Payroll Team', [
              'Make payroll adjustments based on ES&A inputs',
              'Process maintenance, fuel, and driver reimbursements',
            ]),
            const SizedBox(height: 12),
            _buildResponsibilityCard('CHRO', [
              'Overall process and policy ownership',
            ]),
            const SizedBox(height: 20),

            // 11. EXCEPTION/AMENDMENT
            _buildSectionHeader('11. EXCEPTION / AMENDMENT / MODIFICATION'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(254, 243, 199, 1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color.fromRGBO(251, 191, 36, 1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.warning_amber, size: 20, color: Color.fromRGBO(217, 119, 6, 1)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Any exception, amendment, or modification to this policy requires approval of CHRO and CEO&MD.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromRGBO(120, 53, 15, 1),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Copyright
            const Divider(thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: const [
                  Text(
                    '© 2025 The Tata Power Co. Ltd.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromRGBO(107, 114, 128, 1),
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Under Development',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color.fromRGBO(156, 163, 175, 1),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(17, 24, 39, 1),
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildSubSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(55, 65, 81, 1),
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildContentText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        height: 1.6,
        color: Color.fromRGBO(75, 85, 99, 1),
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 13, color: Color.fromRGBO(75, 85, 99, 1))),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color.fromRGBO(75, 85, 99, 1),
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedPoint(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(133, 133, 133, 0.9607843137254902),
                fontFamily: 'Inter',
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color.fromRGBO(75, 85, 99, 1),
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(229, 231, 235, 1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildTableRow('Grade', 'Ex-SR', 'MNT', 'Fuel', 'Driver', isHeader: true),
          _buildTableRow('MA', '₹20L', '₹5,000', '₹19,000', '₹12,000'),
          _buildTableRow('MB', '₹12L', '₹4,000', '₹16,000', '₹11,000'),
          _buildTableRow('MC', '₹10L', '₹3,500', '₹14,500', '₹10,000'),
          _buildTableRow('MD', '₹8L', '₹3,000*', '₹9,500*', '₹8,000*'),
          _buildTableRow('ME', 'NA', '₹2,500*', '₹8,000*', '₹8,000*', isLast: true),
        ],
      ),
    );
  }

  Widget _buildTopUpTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(229, 231, 235, 1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildTableRow('Grade', 'Maintenance', 'Fuel', 'Driver', '', isHeader: true, columnCount: 4),
          _buildTableRow('MA', '₹3,000', '₹6,000', '₹8,000', '', columnCount: 4),
          _buildTableRow('MB', '₹2,000', '₹6,000', '₹8,000', '', columnCount: 4),
          _buildTableRow('MC', '₹2,000', '₹5,000', '₹7,000', '', columnCount: 4),
          _buildTableRow('MD', '₹2,000', '₹4,000', '₹6,000', '', columnCount: 4),
          _buildTableRow('ME', '₹1,500', '₹3,000', '₹3,000', '', isLast: true, columnCount: 4),
        ],
      ),
    );
  }

  Widget _buildTableRow(String col1, String col2, String col3, String col4, String col5,
      {bool isHeader = false, bool isLast = false, int columnCount = 5}) {
    return Container(
      decoration: BoxDecoration(
        color: isHeader ? const Color.fromRGBO(243, 244, 246, 1) : Colors.white,
        border: isLast ? null : const Border(
          bottom: BorderSide(color: Color.fromRGBO(229, 231, 235, 1), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: columnCount == 5
            ? [
          Expanded(flex: 2, child: _buildTableCell(col1, isHeader)),
          Expanded(flex: 2, child: _buildTableCell(col2, isHeader)),
          Expanded(flex: 2, child: _buildTableCell(col3, isHeader)),
          Expanded(flex: 2, child: _buildTableCell(col4, isHeader)),
          Expanded(flex: 2, child: _buildTableCell(col5, isHeader)),
        ]
            : [
          Expanded(flex: 2, child: _buildTableCell(col1, isHeader)),
          Expanded(flex: 2, child: _buildTableCell(col2, isHeader)),
          Expanded(flex: 2, child: _buildTableCell(col3, isHeader)),
          Expanded(flex: 2, child: _buildTableCell(col4, isHeader)),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, bool isHeader) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
        color: isHeader ? const Color.fromRGBO(17, 24, 39, 1) : const Color.fromRGBO(75, 85, 99, 1),
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildScenarioCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(249, 250, 251, 1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color.fromRGBO(229, 231, 235, 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color.fromRGBO(154, 154, 154, 1.0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(17, 24, 39, 1),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color.fromRGBO(75, 85, 99, 1),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsibilityCard(String role, List<String> responsibilities) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(249, 250, 251, 1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color.fromRGBO(229, 231, 235, 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(17, 24, 39, 1),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          ...responsibilities.map((resp) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 12, color: Color.fromRGBO(75, 85, 99, 1))),
                Expanded(
                  child: Text(
                    resp,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromRGBO(75, 85, 99, 1),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}