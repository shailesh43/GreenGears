import 'package:flutter/material.dart';
import '../screens/esna_assign_screen.dart';
import '../screens/esna_spoc_screen.dart';
import '../screens/insurance_screen.dart';

class ProcessingPage extends StatelessWidget {
  const ProcessingPage({Key? key}) : super(key: key);

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
            _buildCard(
              context,
              title: 'Assign ES&A spoc',
              subtitle: 'List of ES&As spoc assignment requests',
              imagePath: 'assets/images/assign_esna.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Sample1()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              title: 'ES&A spoc',
              subtitle: 'List of requests which has to be assigned to insurance',
              imagePath: 'assets/images/esna_spoc.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Sample2()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              title: 'Insurance',
              subtitle: 'List of requests which has to provide insurance statements',
              imagePath: 'assets/images/insurance.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Sample3()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, {
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
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Image.asset(
              imagePath,
              width: 48,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screens
class Sample1 extends StatelessWidget {
  const Sample1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sample 1')),
      body: const Center(child: Text('Sample 1 Screen')),
    );
  }
}

class Sample2 extends StatelessWidget {
  const Sample2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sample 2')),
      body: const Center(child: Text('Sample 2 Screen')),
    );
  }
}

class Sample3 extends StatelessWidget {
  const Sample3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sample 3')),
      body: const Center(child: Text('Sample 3 Screen')),
    );
  }
}