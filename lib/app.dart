import 'dart:async';
import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';

// Construct pages through shell
import 'core/dashboard_shell.dart';
// SAMAL(msauth) Login & logout function
import './auth/azure_auth_service.dart';
// Local storage
import './constants/local_prefs.dart';
import './network/api_client.dart';
import './core/utils/enum.dart';


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
    _loginFuture = _checkLoginStatus();
  }

  // Check if user is already logged in
  Future<String?> _checkLoginStatus() async {
    final isLoggedIn = await LocalPrefs.getIsLoggedIn();

    if (isLoggedIn) {
      // User is already logged in, get empId from local storage
      final empId = await LocalPrefs.getEmpCode();
      if (empId != null && empId.isNotEmpty) {
        return empId;
      }
    }

    // User is not logged in, perform login
    return _login();
  }

  // Login method that returns empId
  Future<String?> _login() async {
    final empId = await AuthenticationService.login();

    if (empId != null) {
      await LocalPrefs.saveEmpId(empCode: empId);
      // Save login status as true
      await LocalPrefs.saveLoginStatus(isLoggedIn: true);
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

      // Save roleId to local storage
      await LocalPrefs.saveRoleId(roleId: roleId);

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
                    '404 :(',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -0.8, color: Colors.redAccent),
                  ),
                  const Text(
                    'Error! Login failed Please try again.',
                    style: TextStyle(fontSize: 18, letterSpacing: -0.2, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loginFuture = _login();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.80), // glass effect
                      foregroundColor: Colors.black,
                      elevation: 6,
                      shadowColor: Colors.black.withOpacity(0.20),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        color: Color.fromRGBO(80, 80, 80, 1.0),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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