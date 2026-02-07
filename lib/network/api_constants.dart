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


  // API Endpoints on dashboard
  static const String roleByEmployee = 'role-by-employee';
  static const String employeeProfile = 'employees';
  static const String carEligibility = 'getCarEligibility';

  // Get data
  static const String getAllRequests = 'AdminPage';
  static const String getListOfEsna = 'getEmployeesRoleDetail';
  static const String getStatusFilteredRequests = 'car-request-data';
  static const String getUserApprovalRequest = 'userApprovalType';

  // Create New Request
  // API call flow: employeeProfile -> createNewEmployee -> createVehicleRequest -> uploadQuotationDoc
  static const String createNewEmployee = 'newEmployee';  // { emp_id, name, grade, email, dob, contact, company, worklocation, eligibility, cost_centre, retirement_date, cluster, department, company_code }
  static const String createVehicleRequest = 'car-requests';  // { emp_id, car_model, manufacturer, purpose, choice_of_lease, color_choice, vehicle_type, quotation, cooling_period, updated_by, comments }
  static const String uploadDocument = 'uploadDocuments'; // { emp_id, process_stage, doc_id, files }

  // Delete Car Request
  static const String deleteRequest = 'DeleteRequest'; // { request_id, role, updated_by }

  // StageWise flow
  static const String decrementStage = 'updateStage';
  static const String assignESNA = 'update-assigned-esna'; // 20 -> 21
  static const String assignInsurance = 'saveOrUpdateCommentAndIncrementStage'; // 21 -> 22
  static const String insuranceQuoteApprovalUser = 'updateInsuranceQuotes'; // 22 -> 23

  // User screens
  static const String firstUserApproval = 'insurance-quote-approval'; // 23 -> 24
  static const String secondUserApproval = ''; // 25 -> 26

  // Processing Screens (ES&A and Insurance)
  static const String monthlyDeduction = 'saveOrUpdateCommentAndIncrementStage'; // 24 -> 25


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
      case "getAllRequests":
        endPointUrl = "$baseURl$getAllRequests";
        break;
      case "getListOfEsna":
        endPointUrl = "$baseURl$getListOfEsna";
        break;
      case "getStatusFilteredRequests":
        endPointUrl = "$baseURl$getStatusFilteredRequests";
        break;
      case "getUserApprovalRequest":
        endPointUrl = "$baseURl$getUserApprovalRequest";
        break;
      case "createVehicleRequest":
        endPointUrl = "$baseURl$createVehicleRequest";
        break;
      case "createNewEmployee":
        endPointUrl = "$baseURl$createNewEmployee";
        break;
      case "uploadDocument":
        endPointUrl = "$baseURl$uploadDocument";
        break;
      case "deleteRequest":
        endPointUrl = "$baseURl$deleteRequest";
        break;
      case "decrementStage":
        endPointUrl = "$baseURl$decrementStage";
        break;
      case "assignESNA":
        endPointUrl = "$baseURl$assignESNA";
        break;
      case "assignInsurance":
        endPointUrl = "$baseURl$assignInsurance";
        break;
      case "insuranceQuoteApprovalUser":
        endPointUrl = "$baseURl$insuranceQuoteApprovalUser";
        break;
      case "firstUserApproval":
        endPointUrl = "$baseURl$firstUserApproval";
        break;
      case "secondUserApproval":
        endPointUrl = "$baseURl$secondUserApproval";
        break;
      case "emiCalculationEsna":
        endPointUrl = "$baseURl$monthlyDeduction";
        break;
    }
    return endPointUrl;
  }
}




