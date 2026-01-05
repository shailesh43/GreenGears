import 'package:flutter/material.dart';

class EsnaSpocScreen extends StatefulWidget {
  const EsnaSpocScreen({super.key});

  @override
  State<EsnaSpocScreen> createState() => _EsnaSpocScreenState();
}

class _EsnaSpocScreenState extends State<EsnaSpocScreen> {
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
            'Your requests',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Padding(),
    )
  }
}
