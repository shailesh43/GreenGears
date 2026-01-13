import 'package:flutter/material.dart';
import 'azure_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AzureAuthService _authService = AzureAuthService();

  dynamic _result;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _authService.initialize();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final res = await _authService.login();
      setState(() => _result = res);
    } catch (e) {
      debugPrint('Login error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final claims = _result?.idTokenClaims;

    return Scaffold(
      appBar: AppBar(title: const Text('Azure AD Login')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _result == null
            ? ElevatedButton(
          onPressed: _login,
          child: const Text('Login with Microsoft'),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Name: ${claims?['name'] ?? '-'}'),
            Text('Email: ${claims?['preferred_username'] ?? '-'}'),
          ],
        ),
      ),
    );
  }
}
