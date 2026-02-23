import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For PlatformException
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../network/api_constants.dart';
import '../constants/local_prefs.dart';
import './token.dart';
import 'package:logger/logger.dart';
import 'dart:io'; // For SocketException
import 'dart:async'; // For TimeoutException
import 'dart:convert'; // For jsonDecode

class AuthenticationService {
  // LOGIN - Returns empId only
  static Future<String?> login() async {
    try {
      // Step 1: Build authorization URL
      final authUri = Uri.parse(ApiConstants.authorizationEndpoint).replace(
        queryParameters: {
          'client_id': ApiConstants.clientId,
          'response_type': 'code',
          'redirect_uri': ApiConstants.redirectUri,
          'response_mode': 'query',
          'scope': ApiConstants.scope,
          'prompt': 'select_account',
        },
      );

      debugPrint('🔐 Starting authentication...');
      debugPrint('Auth URL: ${authUri.toString()}');
      debugPrint('Redirect URI: ${ApiConstants.redirectUri}');

      // Step 2: Authenticate with Microsoft
      // IMPORTANT: Use 'msauth' for signature hash format
      final result = await FlutterWebAuth2.authenticate(
        url: authUri.toString(),
        callbackUrlScheme: 'msauth',  // Changed from 'msauth.com.tatapower.greengears'
      );

      debugPrint('✅ Authentication callback received');
      debugPrint('Result: $result');

      // Step 3: Extract authorization code
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        debugPrint('❌ Authorization code missing');
        throw Exception('Authorization code not found in callback');
      }

      debugPrint('✅ Authorization code received');

      // Step 4: Exchange code for access token
      final tokenResponse = await http.post(
        Uri.parse(ApiConstants.tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': ApiConstants.clientId,
          'scope': ApiConstants.scope,
          'code': code,
          'redirect_uri': ApiConstants.redirectUri,
          'grant_type': 'authorization_code',
        },
      );

      if (tokenResponse.statusCode != 200) {
        debugPrint('❌ Token exchange failed: ${tokenResponse.statusCode}');
        debugPrint('Response: ${tokenResponse.body}');
        throw Exception('Failed to exchange token: ${tokenResponse.statusCode}');
      }

      final tokenData = jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      if (accessToken == null) {
        debugPrint('❌ Access token missing from response');
        throw Exception('Access token not found in token response');
      }

      debugPrint('✅ Access token received');

      // Step 5: Fetch user info from Microsoft Graph
      final userResponse = await http.get(
        Uri.parse(ApiConstants.userGraphUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (userResponse.statusCode != 200) {
        debugPrint('❌ User info fetch failed: ${userResponse.statusCode}');
        debugPrint('Response: ${userResponse.body}');
        throw Exception('Failed to fetch user info: ${userResponse.statusCode}');
      }

      final userData = jsonDecode(userResponse.body);

      // Step 6: Extract employee ID
      const extensionKey = 'extension_6d1109881ca84719973dbff443d7b820_employeeNumber';
      final empId = userData[extensionKey]?.toString();

      if (empId == null || empId.isEmpty) {
        debugPrint('❌ Employee ID not found in user data');
        debugPrint('Available keys: ${userData.keys.join(", ")}');
        throw Exception('Employee ID not found in user profile');
      }

      debugPrint('✅ Login successful - Employee ID: $empId');
      return empId;

    } on PlatformException catch (e) {
      debugPrint('❌ Platform error: ${e.code} - ${e.message}');
      if (e.code == 'CANCELED') {
        debugPrint('ℹ️ User canceled login');
      } else {
        debugPrint('Details: ${e.details}');
      }
      return null;

    } on TimeoutException catch (e) {
      debugPrint('❌ Timeout error: $e');
      return null;

    } on FormatException catch (e) {
      debugPrint('❌ JSON parsing error: $e');
      return null;

    } on SocketException catch (e) {
      debugPrint('❌ Network error: $e');
      return null;

    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<Token> refreshToken(
      BuildContext context, String? refreshToken) async {
    if (refreshToken == null) {
      // If no refresh token, perform full login
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

      final response = await http.post(
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

    // Clear login status from local storage
    await LocalPrefs.saveLoginStatus(isLoggedIn: false);
  }
}
