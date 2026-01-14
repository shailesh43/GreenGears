import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../config/app_config.dart';
import '../constants/local_const.dart';
import 'package:logger/logger.dart';

class AuthenticationService {
  /// 🔐 LOGIN - Returns user info map
  static Future<Map<String, dynamic>?> login() async {
    try {
      // 1️⃣ Build authorization URL
      final authUrl =
          '${AppConfig.authorizationEndpoint}?'
          'client_id=${AppConfig.clientId}'
          '&response_type=code'
          '&redirect_uri=${Uri.encodeComponent(AppConfig.redirectUri)}'
          '&response_mode=query'
          '&scope=${Uri.encodeComponent(AppConfig.scope)}';
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
        Uri.parse(AppConfig.tokenEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': AppConfig.clientId,
          'scope': AppConfig.scope,
          'code': code,
          'redirect_uri': AppConfig.redirectUri,
          'grant_type': 'authorization_code',
        },
      );

      final tokenData = jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      Map<String, String> headers = {
        "Authorization": 'Bearer $accessToken',
        'Content-Type': 'application/json'
      };
      var url = Uri.parse(AppConfig.userGraphUrl);
      var response = await http.get(url, headers: headers);
      final userData = jsonDecode(response.body);

      final empName = userData['givenName'];
      final empMail = userData['mail'];
      final empId = userData['extension_6d1109881ca84719973dbff443d7b820_employeeNumber'];

      print('Employee ID: $empId');
      print('Employee Name: $empName');
      print('Employee Email: $empMail');

      // Return user info as a map
      return {
        'empId': empId,
        'empName': empName,
        'empMail': empMail,
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
    final logoutUrl = '${AppConfig.authorizationEndpoint.replaceAll('/authorize', '/logout')}?'
        'post_logout_redirect_uri=${Uri.encodeComponent(AppConfig.redirectUri)}';

    await FlutterWebAuth2.authenticate(
      url: logoutUrl,
      callbackUrlScheme: 'msauth',
    );
  }
}