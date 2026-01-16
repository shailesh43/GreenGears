// API response: GET "role-by-employee/:empId"
class RoleByEmployeeModel {
  final List<int> roleIds;

  RoleByEmployeeModel({
    required this.roleIds,
  });

  factory RoleByEmployeeModel.fromJson(Map<String, dynamic> json) {
    return RoleByEmployeeModel(
      roleIds: List<int>.from(json['role_ids'] ?? []),
    );
  }
}
