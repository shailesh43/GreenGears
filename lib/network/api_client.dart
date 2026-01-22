import 'dart:convert';
import 'package:http/http.dart' as http;
import './api_constants.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../core/encrypt.dart';
import 'dart:math';        // for Random.secure()
import 'dart:typed_data'; // for Uint8List

import 'dart:async';
import 'package:logger/logger.dart';
import './api_models/role_by_employee.dart'; // 1
import './api_models/employee_profile_data.dart'; // 2
import './api_models/car_eligibility_data.dart'; // 3
import './api_models/admin_page_response.dart'; // 5
import './api_models/stage_bucket.dart'; // 5
import './api_models/role_stage_policy.dart'; // 5
import './api_models/car_request.dart'; // 5

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
  Map<String, dynamic> _handleResponse(http.Response response, String method) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body);
    } else {
      throw Exception(
        '$method $statusCode: ${response.body}',
      );
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

    final data = _handleResponse(response, 'GET');
    return RoleByEmployeeModel.fromJson(data);
  }

  // 2. Fetch Employee Details on ProfilePage (empId)
  // API Endpoint: /employees (POST request with encrypted empId)
  Future<EmployeeProfileData?> getEmployeeProfile(String empId) async {
    try {
      logger.d('Starting getEmployeeProfile for empId: $empId');

      // Encrypt the empId before sending
      final encryptedEmpId = encryptData(empId);
      logger.d('Encrypted empId: $encryptedEmpId');

      if (encryptedEmpId == null) {
        throw Exception('Failed to encrypt employee ID');
      }

      final headers = _defaultHeaders();

      final map = {
        'sap_emp_no': encryptedEmpId,
      };
      final requestBody = jsonEncode(map);
      logger.d('Request body: $requestBody');

      final fullUrl = await ApiConstants.getEndPointUrl("employeeProfile");
      final url = Uri.parse(fullUrl);
      logger.d('Request URL: $url');

      final response = await _client.post(
        url,
        body: requestBody,
        headers: headers,
        encoding: utf8,
      );

      logger.d('Response status code: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.d('Decoded data: $data');
        EmployeeProfileData employeeProfile = EmployeeProfileData.fromJson(data);
        logger.d('Parsed employee profile successfully');
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
  // API Endpoint: /employees (POST request with encrypted empId)
  Future<String?> getCarEligibilityExShowroomPrice(String workLevel) async {
    try {
      logger.d('Starting getCarEligibilityExShowroomPrice for workLevel: $workLevel');

      final headers = _defaultHeaders();

      final map = {
        'work_level': workLevel,
      };

      final requestBody = jsonEncode(map);
      logger.d('Request body: $requestBody');

      final fullUrl = await ApiConstants.getEndPointUrl("getCarEligibility"); // endpoint key
      final url = Uri.parse(fullUrl);
      logger.d('Request URL: $url');

      final response = await _client.post(
        url,
        body: requestBody,
        headers: headers,
        encoding: utf8,
      );

      logger.d('Response status code: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.d('Decoded data: $data');

        final eligibility = CarEligibilityData.fromJson(data);

        logger.d(
          'Parsed car eligibility price: ${eligibility.carEligibilityExShowroomPrice}',
        );

        // ✅ MOST IMPORTANT: returning String
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

  // 4.
  // 5. Fetch All Requests - ROLES: User, Admin, ES&A, Insurance based on ENUMS: UserRole, Stage
  Future<AdminPageResponse> getAdminPageData({
    required String empId,
    required List<int> roleIds,
  }) async {
    final endpointUrl =
    await ApiConstants.getEndPointUrl('getAllRequests');

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

    final data = _handleResponse(response, 'POST');
    return AdminPageResponse.fromJson(data);
  }

}