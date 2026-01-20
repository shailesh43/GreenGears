import 'package:shared_preferences/shared_preferences.dart';

class LocalPrefs {
  static const _empCode = 'emp_code';
  static const _empName = 'emp_name';
  static const _empEmail = 'emp_email';
  static const _empMobile = 'emp_mobile'; = 'emp_email';
  static const _roleId = 'role_id';

  // SAVE Employee Profile
  static Future<void> saveEmployeeProfile({
    required String empCode,
    required String empName,
    required String empEmail,
    required String empMobile,
    required int roleId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // SETTERS
    await prefs.setString(_empCode, empCode);
    await prefs.setString(_empName, empName);
    await prefs.setString(_empEmail, empEmail);
    await prefs.setString(_empMobile, empMobile);
    await prefs.setInt(_roleId, roleId);

  }

  // GETTERS
  static Future<String?> getEmpCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_empCode);
  }

  static Future<String?> getEmpName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_empName);
  }

  static Future<String?> getEmpEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_empEmail);
  }

  static Future<int?> getRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_roleId);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
