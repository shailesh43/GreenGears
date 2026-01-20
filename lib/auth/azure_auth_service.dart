import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../network/api_constants.dart';
import '../constants/local_prefs.dart';
import 'package:logger/logger.dart';

class AuthenticationService {
  /// 🔐 LOGIN - Returns user info map
  static Future<Map<String, dynamic>?> login() async {
    try {
      // 1️⃣ Build authorization URL
      final authUrl =
          '${ApiConstants.authorizationEndpoint}?'
          'client_id=${ApiConstants.clientId}'
          '&response_type=code'
          '&redirect_uri=${Uri.encodeComponent(ApiConstants.redirectUri)}'
          '&response_mode=query'
          '&scope=${Uri.encodeComponent(ApiConstants.scope)}';
          '&prompt=select_account';

      // Microsoft login page
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: 'msauth',
      );

      // Extract authorization code
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        throw Exception('Authorization failed');
      }

      var logger = Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
      );

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

      Map<String, String> headers = {
        "Authorization": 'Bearer $accessToken',
        'Content-Type': 'application/json'
      };
      var url = Uri.parse(ApiConstants.userGraphUrl);
      var response = await http.get(url, headers: headers);
      final userData = jsonDecode(response.body);

      final empName = userData['givenName'];
      final empMail = userData['mail'];
      final empId = userData['extension_6d1109881ca84719973dbff443d7b820_employeeNumber'];

      print('Employee ID from SAMAL: $empId');

      // Return user info as a map
      return {
        'empId': empId,
        'accessToken': accessToken,
      };
    } catch (err) {
      var logger = Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
      );
      logger.e('Error fetching user info: $err');
      return null;
    }
  }

  static Future<void> logout() async {
    final logoutUrl = '${ApiConstants.authorizationEndpoint.replaceAll('/authorize', '/logout')}?'
        'post_logout_redirect_uri=${Uri.encodeComponent(ApiConstants.redirectUri)}';

    await FlutterWebAuth2.authenticate(
      url: logoutUrl,
      callbackUrlScheme: 'msauth',
    );
  }
}