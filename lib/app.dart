import 'package:flutter/material.dart';
import 'core/user_role.dart';
import './auth/login.dart';
import './auth/azure_auth_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Login method that returns user info
  Future<Map<String, dynamic>?> _login() async {
    try {
      final userInfo = await AuthenticationService.login();
      if (userInfo != null) {
        return userInfo;
      }
      return null;
    } catch (e) {
      print('Login failed: $e');
      return null;
    }
  }

  // Determine user role based on userInfo
  UserRole _determineUserRole(Map<String, dynamic> userInfo) {
    final empMail = userInfo['empMail'] ?? '';
    if (empMail.contains('admin') || empMail.endsWith('@admin.tatapower.com')) {
      return UserRole.admin;
    }
    return UserRole.user;
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
      home: FutureBuilder<Map<String, dynamic>?>(
        future: _login(),
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
            final userInfo = snapshot.data!;
            return DashboardShell(
              role: _determineUserRole(userInfo),
              empName: userInfo['empName'] ?? '',
              empId: userInfo['empId'] ?? '',
              empMail: userInfo['empMail'] ?? '',
            );
          }

          // Login failed - show error message
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Login failed',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger rebuild to retry login
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Retry'),
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