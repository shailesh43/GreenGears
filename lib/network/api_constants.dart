import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {

  // BASEURL of GreenGears node backend
  // static String baseURl = "http://localhost:3010/api/";

  // BASEURL of GreenGears Production backend
  static String baseURl = "https://bizapps.tatapower.com/api/greengears/carmanagement/api/";

  // SAMAL auth credentials & URL params
  static String get tenantId => dotenv.env['TENANT_ID'] ?? '';
  static String get clientId => dotenv.env['CLIENT_ID'] ?? '';
  static String get redirectUri {
    if (Platform.isIOS) {
      return dotenv.env['REDIRECT_URI_IOS']!;
    } else {
      return dotenv.env['REDIRECT_URI_ANDROID']!;
    }
  }
  static String get scope => dotenv.env['SCOPE'] ?? 'User.Read offline_access';
  static String get userGraphUrl => dotenv.env['USER_GRAPH_URL'] ?? 'https://graph.microsoft.com/beta/me';
  static String get authorizationEndpoint =>
      'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize';
  static String get tokenEndpoint =>
      'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token';

  // LocalPrefs Endpoints
  static const String roleByEmployee = 'role-by-employee';
  static const String employeeProfile = 'employees';
  static const String carEligibility = 'getCarEligibility';

  // Get data
  static const String getAllRequests = 'AdminPage';
  static const String getListOfEsna = 'getEmployeesRoleDetail';
  static const String getStatusFilteredRequests = 'car-request-data';
  static const String getUserApprovalRequest = 'userApprovalType';
  static const String getAllUploadedDocuments = 'getAllUploadedDocuments';
  static const String getCommentsByRequestId = 'getCommentsByRequestId';

  // Create New Request
  // API call flow: employeeProfile -> createNewEmployee -> uploadQuotationDoc -> createVehicleRequest
  static const String createNewEmployee = 'newEmployee';
  static const String createVehicleRequest = 'car-requests';
  static const String uploadDocument = 'uploadDocuments';

  // Delete Car Request
  static const String deleteRequest = 'DeleteRequest'; // Anything -> 120

  // StageWise flow
  static const String decrementStage = 'updateStage'; // {26 -> 25, 21 -> 20, 23 -> 22}
  static const String assignESNA = 'update-assigned-esna'; // 20 -> 21
  static const String assignInsurance = 'saveOrUpdateCommentAndIncrementStage'; // 21 -> 22
  static const String insuranceQuoteApprovalUser = 'updateInsuranceQuotes'; // 22 -> 23

  // User screens
  static const String firstUserApproval = 'insurance-quote-approval'; // 23 -> 24
  static const String secondUserApproval = ''; // 25 -> 26

  // Processing Screens (ES&A and Insurance)
  static const String monthlyDeduction = 'saveOrUpdateCommentAndIncrementStage'; // 24 -> 25
  static const String paymentDetails = 'saveOrUpdateCommentAndIncrementStage'; // 24 -> 25
  static const String rtoTaxReceipt = 'saveOrUpdateCommentAndIncrementStage'; // 24 -> 25

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
      case "paymentDetailsEsna":
        endPointUrl = "$baseURl$paymentDetails";
        break;
      case "rtoTaxReceipt":
        endPointUrl = "$baseURl$rtoTaxReceipt";
        break;
      case "commentsByRequestId":
        endPointUrl = "$baseURl$getCommentsByRequestId";
        break;
      case "getAllUploadedDocuments":
        endPointUrl = "$baseURl$getAllUploadedDocuments";
        break;
    }
    return endPointUrl;
  }
}




