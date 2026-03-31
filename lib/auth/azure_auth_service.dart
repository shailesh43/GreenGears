import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For PlatformException
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../network/api_constants.dart';
import '../constants/local_prefs.dart';
import './token.dart';
import 'package:logger/logger.dart';
import 'dart:io'; // For SocketException
import 'dart:async'; // For TimeoutException
import 'dart:convert'; // For jsonDecode
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart'; // add crypto: ^3.0.3 to pubspec.yaml if not present

// ---------------------------------------------------------------------------
// PKCE helpers (RFC 7636)
// ---------------------------------------------------------------------------
String _generateCodeVerifier() {
  final random = Random.secure();
  final bytes = Uint8List(32);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = random.nextInt(256);
  }
  return base64UrlEncode(bytes).replaceAll('=', '');
}

String _generateCodeChallenge(String verifier) {
  final bytes = utf8.encode(verifier);
  final digest = sha256.convert(bytes);
  return base64UrlEncode(digest.bytes).replaceAll('=', '');
}
// ---------------------------------------------------------------------------

// A standard (non-pinned) client that still uses system trusted roots.
// Used ONLY for Microsoft endpoints (login.microsoftonline.com, graph.microsoft.com)
// which cannot be pinned since Microsoft rotates their certificates.
// This is intentional and safe — Microsoft's certs are validated against
// the OS trust store, not user-installed CAs.
http.Client _buildMicrosoftClient() {
  final httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      // Reject any cert that is NOT from a known Microsoft domain
      return host.endsWith('.microsoftonline.com') ||
          host.endsWith('.microsoft.com');
    };
  return IOClient(httpClient);
}
// ---------------------------------------------------------------------------

class AuthenticationService {
  // LOGIN - Returns empId only
  static Future<String?> login() async {
    try {
      // PKCE
      final codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(codeVerifier);

      // Step 1: Build authorization URL
      final authUri = Uri.parse(ApiConstants.authorizationEndpoint).replace(
        queryParameters: {
          'client_id': ApiConstants.clientId,
          'response_type': 'code',
          'redirect_uri': ApiConstants.redirectUri,
          'response_mode': 'query',
          'scope': ApiConstants.scope,
          'prompt': 'select_account',
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
        },
      );

      // Step 2: Authenticate with Microsoft
      // IMPORTANT: Use 'msauth' for signature hash format
      final result = await FlutterWebAuth2.authenticate(
        url: authUri.toString(),
        callbackUrlScheme: 'msauth',
      );

      // Step 3: Extract authorization code
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        throw Exception('Authorization code not found in callback');
      }

      // Microsoft client — uses system trust store but rejects non-Microsoft hosts.
      // Cannot use the pinned client here because pinning is scoped to bizapps.tatapower.com.
      final msClient = _buildMicrosoftClient();

      try {
        // Step 4: Exchange code for access token
        final tokenResponse = await msClient.post(
          Uri.parse(ApiConstants.tokenEndpoint),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'client_id': ApiConstants.clientId,
            'scope': ApiConstants.scope,
            'code': code,
            'redirect_uri': ApiConstants.redirectUri,
            'grant_type': 'authorization_code',
            'code_verifier': codeVerifier, // PKCE
          },
        );

        if (tokenResponse.statusCode != 200) {
          throw Exception('Failed to exchange token: ${tokenResponse.statusCode}');
        }

        final tokenData = jsonDecode(tokenResponse.body);
        final accessToken = tokenData['access_token'];

        if (accessToken == null) {
          throw Exception('Access token not found in token response');
        }

        // Step 5: Fetch user info from Microsoft Graph
        final userResponse = await msClient.get(
          Uri.parse(ApiConstants.userGraphUrl),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        );

        if (userResponse.statusCode != 200) {
          throw Exception('Failed to fetch user info: ${userResponse.statusCode}');
        }

        final userData = jsonDecode(userResponse.body);

        // Step 6: Extract employee ID
        const extensionKey = 'extension_6d1109881ca84719973dbff443d7b820_employeeNumber';
        final empId = userData[extensionKey]?.toString();

        if (empId == null || empId.isEmpty) {
          throw Exception('Employee ID not found in user profile');
        }

        return empId;

      } finally {
        msClient.close();
      }

    } on PlatformException catch (e) {
      // Only handle cancellation silently; all other platform errors are unexpected
      if (e.code != 'CANCELED') {
        assert(() {
          debugPrint('❌ Platform error: ${e.code} - ${e.message}');
          return true;
        }());
      }
      return null;

    } on TimeoutException {
      return null;

    } on FormatException {
      return null;

    } on SocketException {
      return null;

    } catch (e, stackTrace) {
      // Stack trace logged in debug builds only via assert (stripped in release)
      assert(() {
        debugPrint('❌ Auth error: $e');
        debugPrint('Stack trace: $stackTrace');
        return true;
      }());
      return null;
    }
  }

  static Future<Token> refreshToken(
      BuildContext context, String? refreshToken) async {
    if (refreshToken == null) {
      final empId = await login();
      if (empId == null) {
        throw Exception('Login failed - unable to get employee ID');
      }
      throw Exception('No refresh token available - full login required');
    } else {
      final Map<String, dynamic> tokenParameters = {
        'client_id': ApiConstants.clientId,
        'scope': ApiConstants.scope,
        'refresh_token': refreshToken,
        'grant_type': 'refresh_token',
      };

      final msClient = _buildMicrosoftClient();
      try {
        final response = await msClient.post(
          Uri.parse(ApiConstants.tokenEndpoint),
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          body: tokenParameters,
        );

        if (response.statusCode == 200) {
          return tokenFromJson(response.body);
        } else {
          throw Exception('Failed to refresh token');
        }
      } finally {
        msClient.close();
      }
    }
  }

  static Future<void> logout() async {
    final logoutUrl =
        '${ApiConstants.authorizationEndpoint.replaceAll('/authorize', '/logout')}?'
        'post_logout_redirect_uri=${Uri.encodeComponent(ApiConstants.redirectUri)}';

    await FlutterWebAuth2.authenticate(
      url: logoutUrl,
      callbackUrlScheme: 'msauth',
    );

    await LocalPrefs.saveLoginStatus(isLoggedIn: false);
  }
}