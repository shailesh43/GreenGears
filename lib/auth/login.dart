import 'package:flutter/material.dart';
import './azure_auth_service.dart';
import '../core/user_role.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Automatically call login when the app opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _login();
    });
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final userInfo = await AuthenticationService.login();
      if (userInfo != null && mounted) {
        print("login successful");
        // Navigate to DashboardShell with user info
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DashboardShell(
              role: _determineUserRole(userInfo),
              empName: userInfo['empName'] ?? '',
              empId: userInfo['empId'] ?? '',
              empMail: userInfo['empMail'] ?? '',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Determine user role based on userInfo or other logic
  UserRole _determineUserRole(Map<String, dynamic> userInfo) {
    // Add your logic here to determine if user is admin or regular user
    // For example, check email domain, specific employee IDs, or call another API
    // This is a placeholder - replace with your actual logic
    final empMail = userInfo['empMail'] ?? '';
    if (empMail.contains('admin') || empMail.endsWith('@admin.tatapower.com')) {
      return UserRole.admin;
    }
    return UserRole.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tata Power SSO')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_loading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login with Microsoft'),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}