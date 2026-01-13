import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../config/app_config.dart';
import '../constants/local_const.dart';
import 'package:logger/logger.dart';

class AuthenticationService {
  /// 🔐 LOGIN
  static Future<bool> login() async {
    // 1️⃣ Build authorization URL
    final authUrl =
        '${AppConfig.authorizationEndpoint}?'
        'client_id=${AppConfig.clientId}'
        '&response_type=code'
        '&redirect_uri=${Uri.encodeComponent(AppConfig.redirectUri)}'
        '&response_mode=query'
        '&scope=${Uri.encodeComponent(AppConfig.scope)}';

    // 2️⃣ Open Microsoft login page
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: 'msauth',
    );

    // 3️⃣ Extract authorization code
    final code = Uri.parse(result).queryParameters['code'];
    if (code == null) {
      throw Exception('Authorization failed');
    }
    var logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // Number of method calls to be displayed
        errorMethodCount: 8, // Number of method calls if stacktrace is provided
        lineLength: 120, // Width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
        // Should each log print contain a timestamp
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
    // 4️⃣ Exchange code for token
    logger.d('${AppConfig.clientId}/${AppConfig.scope}/${code}/${AppConfig.redirectUri}/authorization_code');

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
    logger.d(accessToken);
    try {
      //var response = await request.send();
      Map<String, String> headers = {
        "Authorization": 'Bearer $accessToken',
        'Content-Type': 'application/json'
        //"encryptedbody": encryptedText
      };
      var url = Uri.parse(AppConfig.userGraphUrl);
      var response = await http.get(url, headers: headers);
      final tokenData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // AzureLoginResponse loginResponse =
        // azureLoginResponseFromMap(response.body);
        // return loginResponse;
      }
      final employeeName = tokenData['givenName'];
      final employeeEmail = tokenData['mail'];
      final empId = tokenData['extension_6d1109881ca84719973dbff443d7b820_employeeNumber'];
      print('$employeeName/$empId/$employeeEmail');
    } catch (e) {
//6d1109881ca84719973dbff443d7b820
    }


    // if (tokenResponse.statusCode != 200) {
    //   throw Exception('Token exchange failed');
    // }
    // final tokenData = jsonDecode(tokenResponse.body);
    //
    // // final idToken = tokenData['id_token'];
    // //
    // // // 5️⃣ Decode ID token
    // // final decodedToken = JwtDecoder.decode(idToken);
    // // logger.d(decodedToken);
    // final employeeName = tokenData['givenName'];
    //
    // final employeeEmail = tokenData['mail'];
    // var empId = tokenData['extension6D1109881Ca84719973Dbff443D7B820EmployeeNumber'];
    // //empId = decodedToken['extension' + empId+ 'EmployeeNumber'];
    //
    // // 6️⃣ Validate Tata Power email
    // if (employeeEmail == null ||
    //     !employeeEmail.toLowerCase().endsWith('@tatapower.com')) {
    //   throw Exception('Only Tata Power employees are allowed');
    // }
    // print('$employeeName/$empId/$employeeEmail');

    // // 7️⃣ Save locally
    // await LocalPreferences.saveValues(
    //   employeeName: employeeName,
    //   empId: empId,
    //   employeeEmail: employeeEmail,
    // );

    return true;
  }

  /// 🚪 LOGOUT
  // static Future<void> logout() async {
  //   await LocalPreferences.clear();
  // }
}
