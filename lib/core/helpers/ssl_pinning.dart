import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SSLSecurity {
  // See below for how to get this value
  static const String get _pinnedCertFingerprint => dotenv.env['SHA_FINGERPRINT'] ?? '';

  /// Call this at app startup in main()
  static Future<void> checkUserCACertificates(BuildContext context) async {
    if (!Platform.isAndroid) return;

    try {
      // Try connecting to a known-good endpoint with strict validation
      final client = _buildSecureClient();
      await client.get(Uri.parse('https://bizapps.tatapower.com'));
    } on HandshakeException {
      // SSL handshake failed — likely a user CA is intercepting
      _showSecurityWarning(context);
    } catch (_) {
      // Network error etc — ignore for CA detection purposes
    }
  }

  /// Build an HTTP client that only trusts system certificates
  static http.Client buildPinnedClient() {
    return _buildSecureClient();
  }

  static http.Client _buildSecureClient() {
    final ioClient = HttpClient();

    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      // Reject ALL bad certificates — no exceptions
      return false;
    };

    return IOClient(ioClient);
  }

  static void _showSecurityWarning(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Security Warning'),
        content: const Text(
          'A potentially untrusted certificate has been detected on your device. '
              'For your security, please remove any user-installed CA certificates '
              'and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => exit(0), // Force close the app
            child: const Text('Close App'),
          ),
        ],
      ),
    );
  }
}
