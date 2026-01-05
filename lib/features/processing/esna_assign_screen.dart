import 'package:flutter/material.dart';

class EsnaAssignScreen extends StatefulWidget {
  const EsnaAssignScreen({Key? key}) : super(key: key);

  @override
  State<EsnaAssignScreen> createState() => _EsnaAssignScreenState();
}

class _EsnaAssignScreenState extends State<EsnaAssignScreen> {
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
          'Assign ESNA',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Assign ESNA Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
