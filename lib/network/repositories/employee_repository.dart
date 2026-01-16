import '../api_client.dart';
import '../api_constants.dart';
import './api_models/role_by_employee.dart';

class EmployeeRepository {
  final ApiClient _apiClient = ApiClient();

  // 1. Fetch Employee Role by Employee ID (empId)
  // API Endpoint: /role-by-employee/:empId
  Future<RoleByEmployeeModel> getRoleByEmployee(String empId) async {
    final endpoint =
        '${ApiEndpoints.roleByEmployee}/$empId';

    final response = await _apiClient.get(endpoint);

    return RoleByEmployeeModel.fromJson(response);
  }
}

