import 'package:flutter/material.dart';
import './azure_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;



  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final success = await AuthenticationService.login();
      if (success && mounted) {
        //Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  init(){

  }

  // Future<void> _logout() async {
  //   setState(() => _loading = true);
  //   await AuthenticationService.logout();
  //   if (mounted) {
  //     Navigator.pushReplacementNamed(context, '/login');
  //   }
  //   setState(() => _loading = false);
  // }

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
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login with Microsoft'),
              ),
              const SizedBox(height: 16),
              // OutlinedButton(
              //   onPressed: _loading ? null : _logout,
              //   child: const Text('Logout'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
