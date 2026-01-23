import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import '../network/api_constants.dart';
import '../constants/local_prefs.dart';
import 'package:logger/logger.dart';

class AuthenticationService {
  // LOGIN - Returns empId only
  static Future<String?> login() async {
    try {
      final authUrl =
          '${ApiConstants.authorizationEndpoint}?'
          'client_id=${ApiConstants.clientId}'
          '&response_type=code'
          '&redirect_uri=${Uri.encodeComponent(ApiConstants.redirectUri)}'
          '&response_mode=query'
          '&scope=${Uri.encodeComponent(ApiConstants.scope)}'
          '&prompt=select_account';

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: 'msauth',
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        throw Exception('Authorization failed');
      }

      // Exchange code for token
      final tokenResponse = await http.post(
        Uri.parse(ApiConstants.tokenEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': ApiConstants.clientId,
          'scope': ApiConstants.scope,
          'code': code,
          'redirect_uri': ApiConstants.redirectUri,
          'grant_type': 'authorization_code',
        },
      );

      final tokenData = jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      if (accessToken == null) {
        throw Exception('Access token missing');
      }

      // Fetch user info from Graph
      final response = await http.get(
        Uri.parse(ApiConstants.userGraphUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      final userData = jsonDecode(response.body);

      final empId = userData[
      'extension_6d1109881ca84719973dbff443d7b820_employeeNumber'
      ]?.toString();

      if (empId == null || empId.isEmpty) {
        throw Exception('Employee ID not found');
      }

      print('Employee ID from SAMAL: $empId');

      return empId;
    } catch (err) {
      Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
      ).e('Login failed: $err');

      return null;
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
  }
}
