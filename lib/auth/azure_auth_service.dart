import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import '../network/api_constants.dart';
import '../constants/local_prefs.dart';
import './token.dart';
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
