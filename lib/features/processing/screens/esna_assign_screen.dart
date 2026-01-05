import 'package:flutter/material.dart';

class EsnaAssignScreen extends StatefulWidget {
  const EsnaAssignScreen({super.key});

  @override
  State<EsnaAssignScreen> createState() => _EsnaAssignScreenState();
}

class _EsnaAssignScreenState extends State<EsnaAssignScreenState> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Assign ES&A spoc',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        const Center(
          child: Text(
            'List of ES&As spoc assignment requests',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    )
  }
}
