import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ApiConstants {
  static String baseURl = "http://localhost:3010/api/";

  // SAMAL auth credentials
  static String get tenantId => dotenv.env['TENANT_ID'] ?? '';
  static String get clientId => dotenv.env['CLIENT_ID'] ?? '';
  static String get redirectUri => dotenv.env['REDIRECT_URI'] ?? '';
  static String get scope => dotenv.env['SCOPE'] ?? 'User.Read offline_access';
  static String get userGraphUrl => dotenv.env['USER_GRAPH_URL'] ?? 'https://graph.microsoft.com/beta/me';
  static String get authorizationEndpoint =>
      'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize';
  static String get tokenEndpoint =>
      'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token';


  // API Endpoints
  static const String roleByEmployee = 'role-by-employee';
  static const String employeeProfile = 'employees';
  static const String carEligibility = 'getCarEligibility';
  static const String createVehicleRequest = 'car-requests'; // to be continued
  static const String getAllRequests = 'AdminPage';

  // getX function for getting the "API endpoint url"
  static getEndPointUrl(String endPointName) async {
    String endPointUrl = "";
    switch (endPointName) {
      case "roleByEmployee":
        endPointUrl = "$baseURl$roleByEmployee";
        break;
      case "employeeProfile":
        endPointUrl = "$baseURl$employeeProfile";
        break;
      case "getCarEligibility":
        endPointUrl = "$baseURl$carEligibility";
        break;
      case "createVehicleRequest":
        endPointUrl = "$baseURl$createVehicleRequest";
        break;
      case "getAllRequests":
        endPointUrl = "$baseURl$getAllRequests";
        break;
    }
    return endPointUrl;
  }
}




