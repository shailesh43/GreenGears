import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiClient {
  final http.Client _client = http.Client();

  // ---------------- GET ----------------
  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

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
      }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    final response = await _client.post(
      url,
      headers: _defaultHeaders(),
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
  Map<String, dynamic> _handleResponse(
      http.Response response,
      String method,
      ) {
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
}
