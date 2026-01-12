import 'package:flutter/material.dart';
import '../request/request_vehicle.dart';
import '../request/user_approval.dart';
import '../../features/profile/profile_page.dart';
import '../docs/uploaded_quotations.dart';

class DashboardUser extends StatelessWidget {
  const DashboardUser({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenGears',
      theme: ThemeData(
        primaryColor: const Color(0xFF2ECC71),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      extendBodyBehindAppBar: true,
      body: Container(
        child: Column(
          children: [
            // Header
            Container(
              height: 130,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.only(top: 30, bottom: 0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(41, 183, 69, 1),  //PrimaryGreen
                border: Border.all(color: Colors.black, width: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'GreenGears',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        letterSpacing: -0.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Flexible(
                      child: Image.asset(
                        'assets/images/tata_power_logo.png',
                        height: 48,
                        fit: BoxFit.contain,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsGeometry.fromLTRB(24, 4, 24, 16),
                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    const Text(
                      'Welcome',
                      style: TextStyle(fontSize: 24, letterSpacing: -0.4, color: Color(0xFF666666)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Rahil Bopche',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.4,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.20),
                            offset: const Offset(3, 3), // right & bottom
                            blurRadius: 6,
                            spreadRadius: -1, // prevents shadow on top/left
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem('EMP code', '209164'),
                              ),
                              Expanded(child: _buildInfoItem('Grade', 'ME03')),
                              Expanded(
                                child: _buildInfoItem(
                                  'Cost Center',
                                  '1900022041',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  'Eligibility',
                                  '₹5,00,000',
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem('Phone', '+8498475876'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: Color.fromRGBO(41, 183, 69, 0.50),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.edit,
                            title: 'Create Request\nfor your Vehicle',
                            color: Color.fromRGBO(41, 183, 69, 0.55),
                            titleColor: Color.fromRGBO(
                                248, 248, 248, 1.0),
                            iconColor: Color.fromRGBO(248, 248, 248, 1.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const VehicleRequestPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.check_circle_outline,
                            title: 'Approve/Reject\nRequests',
                            color: Color.fromRGBO(242, 241, 249, 1.0),
                            titleColor: Color.fromRGBO(152, 152, 152, 1.0),
                            iconColor: Color.fromRGBO(152, 152, 152, 1.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserApproval(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Quotation docs
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black.withOpacity(0.05),
                        //     blurRadius: 12,
                        //     offset: const Offset(0, 2),
                        //   ),
                        // ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              size: 28,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UploadedQuotations(),
                                ),
                              );
                            },
                            child: Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quotation docs',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(0, 0, 0, 0.80),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'List of uploaded quotation docs till now',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'Inter',

              letterSpacing: -0.2
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF000000),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: iconColor ?? Colors.grey, size: 28),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: titleColor ?? Colors.grey,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}