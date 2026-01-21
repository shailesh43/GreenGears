import 'package:flutter/material.dart';
import 'core/user_role.dart';
import './auth/azure_auth_service.dart';
import './constants/utils.dart';
import './network/api_client.dart';
import './constants/local_prefs.dart';
import 'dart:async';
import 'dart:core';
import 'dart:ui';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ApiClient _client = ApiClient();
  bool isLoading = false;

  late Future<String?> _loginFuture;

  @override
  void initState() {
    super.initState();
    _loginFuture = _login();
  }

  // Login method that returns empId
  Future<String?> _login() async {
    final empId = await AuthenticationService.login();

    if (empId != null) {
      await LocalPrefs.saveEmpId(empCode: empId);
    }

    return empId;
  }

  // Fetch role from API
  Future<UserRole> _fetchEmployeeRole(String empCode) async {
    if (empCode.isEmpty) {
      return UserRole.user; // default fallback
    }

    try {
      final result = await _client.getRoleByEmployee(empCode);
      final roleId = result.roleIds.isNotEmpty ? result.roleIds.first : 1;

      debugPrint('GET 200 OK : "role-by-employee/:empId"');
      debugPrint('roleId: $roleId');

      return UserRole.fromId(roleId) ?? UserRole.user;
    } catch (e) {
      debugPrint('Error fetching role: $e');
      return UserRole.user; // default fallback on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenGears',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FutureBuilder<String?>(
        future: _loginFuture,
        builder: (context, snapshot) {
          // Show loading indicator while authenticating
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Check if login was successful
          if (snapshot.hasData && snapshot.data != null) {
            final empCode = snapshot.data!;
            return FutureBuilder<UserRole>(
              future: _fetchEmployeeRole(empCode),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final role = roleSnapshot.data ?? UserRole.user;
                return DashboardShell(role: role);
              },
            );
          }

          // Login failed - show error message
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '404',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.2, color: Colors.red),
                  ),
                  const Text(
                    'Login failed',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loginFuture = _login();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.85), // glass effect
                      foregroundColor: Colors.black,
                      elevation: 6,
                      shadowColor: Colors.black.withOpacity(0.15),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}