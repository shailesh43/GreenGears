import 'package:shared_preferences/shared_preferences.dart';

class LocalPrefs {
  static const _empCode = 'emp_code';
  static const _empName = 'emp_name';
  static const _empEmail = 'emp_email';
  static const _empMobile = 'emp_mobile';
  static const _roleId = 'role_id';
  static const _empGrade = 'emp_grade';
  static const _empEligibility = 'emp_eligibility';

  static Future<void> saveEmpId({
    required String empCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // SETTER
    await prefs.setString(_empCode, empCode);
  }

  // SAVE Employee Profile
  static Future<void> saveEmployeeProfile({
    String? empName,        // ← Changed from required String
    String? empEmail,       // ← Changed from required String
    String? empMobile,      // ← Changed from required String
    String? empGrade,
    // String? empEligibility,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // SETTERS - only save non-null values
    if (empName != null) {
      await prefs.setString(_empName, empName);
    }
    if (empEmail != null) {
      await prefs.setString(_empEmail, empEmail);
    }
    if (empMobile != null) {
      await prefs.setString(_empMobile, empMobile);
    }
    if (empGrade != null) {
      await prefs.setString(_empGrade, empGrade);
    }
    // if (empEligibility != null) {
    //   await prefs.setString(_empEligibility, empEligibility);
    // }
  }


  static Future<void> saveCarEligibilityPrice({
    required String price,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // SETTER
    await prefs.setString(_empEligibility, price);
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

  static Future<String?> getEmpMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_empMobile);
  }

  static Future<int?> getRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_roleId);
  }

  static Future<String?> getEmpGrade() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_empGrade);
  }

  static Future<String?> getEmpEligibility() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_empEligibility);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}