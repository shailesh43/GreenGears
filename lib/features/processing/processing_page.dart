import 'package:flutter/material.dart';

//Screens
import './assign_esna_screen.dart';
import './esna_spoc_screen.dart';
import './insurance_screen.dart';

// Constants
import '../../core/utils/enum.dart';

class ProcessingPage extends StatefulWidget {
  final UserRole role;

  const ProcessingPage({
    super.key,
    required this.role,
  });

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('Role: ${widget.role}');
  }

  Widget build(BuildContext context) {

    UserRole role = widget.role;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Processing',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Show "Assign ES&A spoc" only for Admin
            if (role == UserRole.admin)
              _buildCard(
                title: 'Assign ES&A spoc',
                subtitle: 'List of ES&As spoc assignment requests',
                imagePath: 'assets/images/assign_esna.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssignEsnaScreen(),
                    ),
                  );
                },
              ),

            if (role == UserRole.admin)
              const SizedBox(height: 16),

            // Show "ES&A spoc" for Admin and ES&A roles
            if (role == UserRole.admin || role == UserRole.esna)
              _buildCard(
                title: 'ES&A spoc',
                subtitle: 'List of requests which has to be assigned to insurance',
                imagePath: 'assets/images/esna_spoc.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EsnaSpocScreen(),
                    ),
                  );
                },
              ),

            if (role == UserRole.admin || role == UserRole.esna)
              const SizedBox(height: 16),

            // Show "Insurance" for Admin and Insurance roles
            if (role == UserRole.admin || role == UserRole.insurance)
              _buildCard(
                title: 'Insurance',
                subtitle: 'List of requests which has to provide insurance statements',
                imagePath: 'assets/images/insurance.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InsuranceScreen(),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          // border: Border.all(color: Colors.black, width: 0.25),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              offset: const Offset(2, 2), // right & bottom shadow
              blurRadius: 4,
              spreadRadius: -1, // prevents shadow on top/left
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.grey,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            /// 🔥 OVERFLOW-SAFE IMAGE
            SizedBox(
              width: 72,
              height: 72,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset(imagePath),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
