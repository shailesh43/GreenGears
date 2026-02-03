import 'dart:convert';
import 'package:http/http.dart' as http;
import './api_constants.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../core/helpers/encrypt.dart';
import 'dart:math';        // for Random.secure()
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/utils/enum.dart';
import '../../core/utils/role_stage_policy.dart';

import 'dart:async';
import 'package:logger/logger.dart';
import './api_models/role_by_employee.dart'; // 1
import './api_models/employee_profile_data.dart'; // 2
import './api_models/car_eligibility_data.dart'; // 3
import './api_models/create_vehicle_response_model.dart'; // 4
import './api_models/create_new_employee_response.dart'; // 4
import './api_models/admin_page_response.dart'; // 5
import './api_models/stage_bucket.dart'; // 5
import './api_models/car_request.dart'; // 5
import './api_models/list_of_esna_model.dart'; // 6
import './api_models/status_filtered_requests_model.dart'; // 7
import './api_models/user_approval_model.dart'; // 8
import './api_models/upload_document_response_model.dart'; // 4

class ApiClient {
  final http.Client _client = http.Client();
  final Logger logger = Logger();

  // ---------------- GET ----------------
  Future<Map<String, dynamic>> get(String endpoint) async {
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
      }) async {
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
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }


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
  // 4.3) API Endpoint: /uploadDocument
  Future<UploadDocumentResponseModel> uploadDocument(
      Map<String, dynamic> body,
      ) async {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('uploadDocument');

    final uri = Uri.parse(endpointUrl);

    final request = http.MultipartRequest('POST', uri);

    // ---------------- Fields ----------------
    request.fields['emp_id'] = body['emp_id'].toString();
    request.fields['process_stage'] =
        body['process_stage'].toString();
    request.fields['doc_id'] = body['doc_id'].toString();

    // ---------------- Files ----------------
    final List<http.MultipartFile> files =
    body['files'] as List<http.MultipartFile>;

    request.files.addAll(files);

    // ---------------- Headers ----------------
    request.headers.addAll(_defaultHeaders()
      ..remove('Content-Type')); // IMPORTANT

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    logger.d('${response.statusCode} > URL: $uri');

    final data = _handleResponse(response, 'POST');
    return UploadDocumentResponseModel.fromJson(data);
  }


  // 5. Fetch All Requests - ROLES: User, Admin, ES&A, Insurance based on ENUMS: UserRole, Stage
  // API Endpoint: /employees (POST request with reqBody : empId, roleIds: [])
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
  // API Endpoint: /getallEmployees
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

  // 7. Filter based requests on Search Screen
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

}