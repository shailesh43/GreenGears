import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

// REFERENCES
import './api_constants.dart';
import '../../core/utils/enum.dart';
import '../../core/utils/role_stage_policy.dart';
import '../core/helpers/encrypt.dart';

// API MODELS
import './api_models/role_by_employee.dart';
import './api_models/employee_profile_data.dart';
import './api_models/car_eligibility_data.dart';
import './api_models/create_vehicle_response_model.dart';
import './api_models/create_new_employee_response.dart';
import './api_models/admin_page_response.dart';
import './api_models/stage_bucket.dart';
import './api_models/car_request.dart';
import './api_models/list_of_esna_model.dart';
import './api_models/status_filtered_requests_model.dart';
import './api_models/user_approval_model.dart';
import './api_models/upload_document_response_model.dart';
import './api_models/delete_request_response_model.dart';
import './api_models/assign_esna_spoc_model.dart';
import './api_models/decrement_stage_model.dart';
import './api_models/assign_to_insurance_model.dart';
import './api_models/insurance_quote_approval_model.dart';
import './api_models/first_user_approval_model.dart';
import './api_models/second_user_approval_model.dart';
import './api_models/submit_by_esna_emi_model.dart';
import './api_models/submit_by_esna_payment_model.dart';
import './api_models/submit_by_esna_receipt_model.dart';
import './api_models/comments_response_model.dart';
import './api_models/get_all_docs_response_model.dart';

class ApiClient {
  final http.Client _client = http.Client();
  final Logger logger = Logger();
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  // ---------------- GET ----------------
  Future<Map<String, dynamic>> get(String endpoint) async
  {
    final url = Uri.parse('${ApiConstants.baseURl}$endpoint');

    final response = await _client.get(
      url,
      headers: _defaultHeaders(),
    );

    return _handleResponse(response, 'GET');
  }

  // ---------------- POST ----------------
  Future<Map<String, dynamic>> post(
      String endpoint, {
        required Map<String, dynamic> body,
        required Map<String, String>? headers,
      }) async
  {
    final url = Uri.parse('${ApiConstants.baseURl}$endpoint');

    final response = await _client.post(
      url,
      headers: headers ?? _defaultHeaders(),
      body: jsonEncode(body),
    );

    return _handleResponse(response, 'POST');
  }

  // ---------------- COMMON HEADERS ----------------
  Map<String, String> _defaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ---------------- RESPONSE HANDLER ----------------
  dynamic _handleResponse(http.Response response, String method) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'API Error [${response.statusCode}]: ${response.body}',
    );
  }

  // ---------------- API ENDPOINTS ----------------

  // 1. Fetch Employee Role on LoginPage (empId)
  // API Endpoint: /role-by-employee/:empId
  Future<RoleByEmployeeModel> getRoleByEmployee(String empId) async {
    final endpointUrl = await ApiConstants.getEndPointUrl('roleByEmployee');
    final fullUrl = '$endpointUrl/$empId';
    final url = Uri.parse(fullUrl);

    final response = await _client.get(
      url,
      headers: _defaultHeaders(),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'GET');
    return RoleByEmployeeModel.fromJson(data);
  }

  // 2. Fetch Employee Details on ProfilePage (empId)
  // API Endpoint: /employees (POST request with encrypted empId)
  Future<EmployeeProfileData?> getEmployeeProfile(String empId) async {
    try {
      // Encrypt the empId before sending
      final encryptedEmpId = encryptData(empId);
      if (encryptedEmpId == null) {
        throw Exception('Failed to encrypt employee ID');
      }

      final headers = _defaultHeaders();

      final map = {
        'sap_emp_no': encryptedEmpId,
      };

      final requestBody = jsonEncode(map);
      final fullUrl = await ApiConstants.getEndPointUrl("employeeProfile");
      final url = Uri.parse(fullUrl);

      final response = await _client.post(
        url,
        body: requestBody,
        headers: headers,
        encoding: utf8,
      );

      logger.d('${response.statusCode} > URL: $url');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        EmployeeProfileData employeeProfile = EmployeeProfileData.fromJson(data);
        return employeeProfile;
      } else {
        logger.d('Non-200 status code received: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.d('Exception in getEmployeeProfile: $e');
      return null;
    }
  }

  // Helper method for encrypting empId before making POST request
  String encryptData(String data) {
    const secretKey = 'testTestTest@1122';

    // CryptoJS uses random 8-byte salt
    final salt = List<int>.generate(8, (_) => Random.secure().nextInt(256));

    // Derive key + IV using EVP_BytesToKey (MD5)
    final keyIv = evpBytesToKey(
      utf8.encode(secretKey),
      salt,
      keySize: 32,
      ivSize: 16,
    );

    final key = encrypt.Key(Uint8List.fromList(keyIv.sublist(0, 32)));
    final iv = encrypt.IV(Uint8List.fromList(keyIv.sublist(32, 48)));

    final encrypter =
    encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(data, iv: iv);

    // CryptoJS output format: "Salted__" + salt + ciphertext
    final result = base64Encode([
      ...utf8.encode('Salted__'),
      ...salt,
      ...encrypted.bytes,
    ]);

    return result;
  }

  // 3. Fetch Car Eligibility Details on ProfilePage, MainDashboard (empId)
  // API Endpoint: /employees (POST request with reqBody : grade)
  Future<String?> getCarEligibilityExShowroomPrice(String workLevel) async {
    try {
      final headers = _defaultHeaders();

      final map = {
        'work_level': workLevel,
      };

      final requestBody = jsonEncode(map);
      final fullUrl = await ApiConstants.getEndPointUrl("getCarEligibility"); // endpoint key
      final url = Uri.parse(fullUrl);

      final response = await _client.post(
        url,
        body: requestBody,
        headers: headers,
        encoding: utf8,
      );

      logger.d('${response.statusCode} > URL: $url');


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final eligibility = CarEligibilityData.fromJson(data);

        return eligibility.carEligibilityExShowroomPrice;
      } else {
        logger.d('Non-200 status code received: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.d('Exception in getCarEligibilityExShowroomPrice: $e');
      return null;
    }
  }

  // 4. Create New Request on CreateRequestScreen
  // 4.1) API Endpoint: /newEmployee
  Future<CreateNewEmployeeResponse> createNewEmployee(
      Map<String, dynamic> body,
      ) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('createNewEmployee');

    final url = Uri.parse(endpointUrl);

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return CreateNewEmployeeResponse.fromJson(data);
  }
  // 4.2) API Endpoint: /car-requests
  Future<CreateVehicleResponseModel> createNewVehicleRequest(
      Map<String, dynamic> body,
      ) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('createVehicleRequest');

    final url = Uri.parse(endpointUrl);

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return CreateVehicleResponseModel.fromJson(data);
  }

  // TODO: Test & Rewrite this endpoint
  // 4.3) API Endpoint: /uploadDocument
  Future<UploadDocumentResponseModel> uploadDocument({
    required Map<String, dynamic> body,
    required void Function(double progress) onProgress,
  }) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('uploadDocument');

    final formData = FormData.fromMap({
      'emp_id': body['emp_id'],
      'process_stage': body['process_stage'],
      'doc_id': body['doc_id'],
      'files': body['files'], // 🔴 MUST be list
    });

    final response = await _dio.post(
      endpointUrl,
      data: formData,
      options: Options(
        headers: {
          ..._defaultHeaders(),
          // ❌ NEVER set Content-Type manually
        },
      ),
      onSendProgress: (sent, total) {
        if (total > 0) {
          final progress = sent / total;
          onProgress(progress); // 0.0 → 1.0
        }
      },
    );

    return UploadDocumentResponseModel.fromJson(response.data);
  }

  // 5. Fetch All Requests - ROLES: User, Admin, ES&A, Insurance based on ENUMS: UserRole, Stage
  // API Endpoint: /AdminPage
  Future<AdminPageResponse> getAdminPageData({
    required String empId,
    required List<int> roleIds,
  }) async
  {
    final endpointUrl = await ApiConstants.getEndPointUrl('getAllRequests');

    final url = Uri.parse(endpointUrl);

    final body = {
      'emp_id': empId,
      'role_ids': roleIds,
    };

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return AdminPageResponse.fromJson(data);
  }

  // 6. Get List of ES&As on AssignEsnaScreen
  // API Endpoint: /getEmployeesRoleDetail
  Future<List<GetListOfEsnaModel>> getListOfEsna() async {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('getListOfEsna');
    final url = Uri.parse(endpointUrl);

    final response = await _client.get(
      url,
      headers: _defaultHeaders(),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'GET');

    return GetListOfEsnaModel.listFromJson(data as List);
  }

  // 7. Filter based requests on Search Screen (ACTIVE/INACTIVE)
  // API Endpoint: /car-request-data
  Future<StatusFilteredRequestsModel> getStatusFilteredRequests({
    required String empId,
    required int role,
  }) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('getStatusFilteredRequests');

    final url = Uri.parse(endpointUrl);

    final body = {
      'emp_id': empId,
      'role': role,
    };

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return StatusFilteredRequestsModel.fromJson(data);
  }

  // 8. User Approval requests on Approve/Reject request screen
  // API Endpoint: /userApprovalType
  Future<UserApprovalModel> getApprovalStages({
    required String empId,
    required int role,
  }) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('getUserApprovalRequest');

    final url = Uri.parse(endpointUrl);

    final body = {
      'emp_id': empId,
      'role': role,
    };

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return UserApprovalModel.fromJson(data);
  }

  // 9. Delete Car Request
  // API Endpoint: /DeleteRequest
  Future<DeleteRequestResponseModel> deleteRequest({
    required String requestId,
    required int role,
    required String empId,
  }) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('deleteRequest');

    final url = Uri.parse(endpointUrl);

    final body = {
      'request_id': requestId,
      'role': role,
      'updated_by': empId,
    };

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return DeleteRequestResponseModel.fromJson(data);
  }

  // 10. Assign ES&A spoc
  // API Endpoint: /update-assigned-esna
  Future<AssignEsnaSpocModel> assignOrUpdateEsnaSpoc({
    required String requestId,
    required String assignedEsnaEmpId,
  }) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('assignESNA');

    final url = Uri.parse(endpointUrl);

    final body = {
      'request_id': requestId,
      'assigned_to': assignedEsnaEmpId,
    };

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return AssignEsnaSpocModel.fromJson(data);
  }

  // 11. Decrement stage
  // API Endpoint: /updateStage :
  Future<DecrementStageModel> decrementStageOnReject({
    required String requestId,
    required String empId,
  }) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('decrementStage');

    final url = Uri.parse(endpointUrl);

    final body = {
      'req_id': requestId,
      'emp_id': empId,
    };

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return DecrementStageModel.fromJson(data);
  }

  // 12. Assign to Insurance
  // API Endpoint: /saveOrUpdateCommentAndIncrementStage
  Future<AssignToInsuranceModel> assignToInsurance({
    required String requestId,
    required String empId,
    required String commentsAssignedToEsna,
  }) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('assignInsurance');

    final url = Uri.parse(endpointUrl);

    final body = {
      'emp_id': empId,
      'req_id': requestId,
      'comments_assigned_to_esna': commentsAssignedToEsna,
    };

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return AssignToInsuranceModel.fromJson(data);
  }

  // 13. Submit for Insurance quote approval
  // API Endpoint: /updateInsuranceQuotes
  Future<InsuranceQuoteApprovalModel> SubmitForInsuranceQuoteApproval({
    required String requestId,
    required int baseInsurance,
    required int addOnTataPower,
    required int addOnSapphirePlus,
    required String commentsByGIT,
  }) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('insuranceQuoteApprovalUser');

    final url = Uri.parse(endpointUrl);

    final body = {
      "request_id": requestId,
      "base_insurance_premium": baseInsurance,
      "add_on_cover_tata_power": addOnTataPower,
      "add_on_sapphire_plus": addOnSapphirePlus,
      "comments_assigned_to_git": commentsByGIT,
      "insurance_expires_on": "2023-12-31",
    };

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return InsuranceQuoteApprovalModel.fromJson(data);
  }

  // 14. Submit By User: First approval (Quotation Approval)
  // API Endpoint: /insurance-quote-approval
  Future<FirstUserApprovalModel> firstUserApproval({
    required String requestId,
    required String userApprovalComments,
    required String addOnTataPower,
    required String addOnSapphirePlus,
  }) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('firstUserApproval');

    final url = Uri.parse(endpointUrl);

    final body = {
      "request_id": requestId,
      "add_on_cover_tata_power": addOnTataPower,
      "add_on_sapphire_plus": addOnSapphirePlus,
      "insurance_quote_approval_user": userApprovalComments,
    };

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return FirstUserApprovalModel.fromJson(data);
  }

  // 15. Submit By User: Second approval (EMI approval)
  // API Endpoint: /
  Future<SecondUserApprovalModel> secondUserApproval({
    required String requestId,
    required String empId,
    required String commentsAssignedToEsna,
  }) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('secondUserApproval');

    final url = Uri.parse(endpointUrl);

    final body = {
      'emp_id': empId,
      'req_id': requestId,
      'comments_assigned_to_esna': commentsAssignedToEsna,
    };

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return SecondUserApprovalModel.fromJson(data);
  }

  // 16. Submit By ESNA: EMI calculation (Monthly deduction)
  // API Endpoint: /saveOrUpdateCommentAndIncrementStage
  Future<SubmitByEsnaEmiModel> submitByEsnaEmi({
    required String requestId,
    required String empId,
    required String commentsAssignedToEsna,
    required String completeEmiTenure,
    required String emiAmount,
    required String totalEmi,
    required String companyContribution,
    required String carAllowance
  }) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('emiCalculationEsna');

    final url = Uri.parse(endpointUrl);

    final body = {
      'emp_id': empId,
      'req_id': requestId,
      'comments_assigned_to_esna': commentsAssignedToEsna,
      'complete_emi_tenure': completeEmiTenure,
      'emi_amount' : emiAmount,
      'total_emi' : totalEmi,
      'company_contribution' : companyContribution,
      'car_allowance': carAllowance,
    };

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return SubmitByEsnaEmiModel.fromJson(data);
  }

  // 17. Submit By ESNA: Purchase order (Payment Details)
  // API Endpoint: /saveOrUpdateCommentAndIncrementStage
  Future<SubmitByEsnaPaymentModel> submitByEsnaPayment({
    required String requestId,
    required String empId,
    required String commentsAssignedToEsna,
  }) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('paymentDetailsEsna');

    final url = Uri.parse(endpointUrl);

    final body = {
      'emp_id': empId,
      'req_id': requestId,
      'comments_assigned_to_esna': commentsAssignedToEsna,
    };

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return SubmitByEsnaPaymentModel.fromJson(data);
  }

  // 18. Submit By ESNA: Vehicle history (RTO Tax receipt)
  // API Endpoint: /saveOrUpdateCommentAndIncrementStage
  Future<SubmitByEsnaReceiptModel> submitByEsnaRtoTaxReceipt({
    required String requestId,
    required String empId,
    required String commentsAssignedToEsna,
    required String vehicleNumber,
    required String vehicleMake,
    required String vehicleModel,
    required String chassisNumber,
    required String engineNumber,
    required String vehicleHandoverDate,
    required String fastTagNumber
  }) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('rtoTaxReceipt');

    final url = Uri.parse(endpointUrl);

    final body = {
      'emp_id': empId,
      'req_id': requestId,
      'comments_rto_tax_receipt_other_docs_esna': commentsAssignedToEsna,
      'vehicle_number' : vehicleNumber,
      'vehicle_make' : vehicleMake,
      'vehicle_model' : vehicleModel,
      'chasis_number' : chassisNumber,
      'engine_number' : engineNumber,
      'vehicle_hand_over_date_to_employee' : vehicleHandoverDate,
      'fast_tag_number' : fastTagNumber,
    };

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return SubmitByEsnaReceiptModel.fromJson(data);
  }

  // 19. GET comments posted by User
  // API Endpoint: /getCommentsByRequestId
  Future<CommentsResponseModel> getCommentsByRequestId({
    required String requestId,
  }) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('commentsByRequestId');

    final url = Uri.parse(endpointUrl);

    final body = {
      'req_id': requestId,
    };

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return CommentsResponseModel.fromJson(data);
  }

  // 19. GET Uploaded Documents posted by specified EmpId
  // API Endpoint: /getAllUploadedDocuments
  Future<GetAllDocsResponseModel> getAllUploadedDocsFromS3({
    required String requestId,
  }) async
  {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('getAllUploadedDocuments');

    final url = Uri.parse(endpointUrl);

    final body = {
      'request_id': requestId,
    };

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );

    logger.d('${response.statusCode} > URL: $url');

    final data = _handleResponse(response, 'POST');
    return GetAllDocsResponseModel.fromJson(data);
  }
}