import 'package:flutter/material.dart';
import 'core/user_role.dart';
import './auth/azure_auth_service.dart';
import './constants/utils.dart';
import './network/api_client.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // const MyApp({super.key});
  final ApiClient _client = ApiClient();
  bool isLoading = false;

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
              final empCode = userInfo['empId'] ?? '';

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