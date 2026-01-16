import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferences {
  static const _keyEmpId = 'emp_id';
  static const _keyRoleIds = 'role_ids';
  static const _keyIsLoggedIn = 'is_logged_in';

  // ---------- SAVE ----------

  static Future<void> saveEmpId(String empId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmpId, empId);
  }

  static Future<void> saveRoleIds(List<int> roleIds) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = roleIds.map((e) => e.toString()).toList();
    await prefs.setStringList(_keyRoleIds, stringList);
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  // ---------- GET ----------

  static Future<String?> getEmpId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmpId);
  }

  static Future<List<int>> getRoleIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyRoleIds) ?? [];
    return list.map(int.parse).toList();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // ---------- CLEAR ----------

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
