import 'dart:convert';
import 'package:http/http.dart' as http;
import './api_constants.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../core/decrypt.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import './api_models/role_by_employee.dart'; // 1
import './api_models/employee_profile_data.dart'; // 2

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
      // Encrypt the empId before sending
      final encryptedEmpId = _encryptData(empId);

      if (encryptedEmpId == null) {
        throw Exception('Failed to encrypt employee ID');
      }

      final headers = _defaultHeaders();

      final map = {
        'sap_emp_no': encryptedEmpId,
      };
      final requestBody = jsonEncode(map);

      final fullUrl = await ApiConstants.getEndPointUrl("employees");
      final url = Uri.parse(fullUrl);

      final response = await _client.post(
        url,
        body: requestBody,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        EmployeeProfileData employeeProfile = EmployeeProfileData.fromJson(data);
        return employeeProfile;
      }
    } catch (e) {
      logger.d(e.toString());
    }
    return null;
  }

  // Helper method to encrypt data (should match your frontend encryption)
  String? _encryptData(String data) {
    try {
      const secretKey = "testTestTest@1122";

      // Create key from the secret string
      final key = encrypt.Key.fromUtf8(secretKey.padRight(32, '\x00').substring(0, 32));

      // Create encrypter with AES algorithm in CBC mode
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

      // Encrypt the data
      final encrypted = encrypter.encrypt(data, iv: encrypt.IV.fromLength(16));

      return encrypted.base64;
    } catch (error) {
      logger.d("Encryption error: $error");
      return null;
    }
  }
}