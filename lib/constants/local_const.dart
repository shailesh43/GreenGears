import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferences {
  static const int preftypeInt = 0;
  static const int preftypeString = 1;
  static const int preftypeBool = 2;

  static saveValues(type, key, value) async {
    final prefs = await SharedPreferences.getInstance();
    if (type == preftypeInt) {
      await prefs.setInt(key, value);
    } else if (type == preftypeString) {
      await prefs.setString(key, value);
    } else if (type == preftypeBool) {
      await prefs.setBool(key, value);
    }
  }

  static Future<bool> getBoolValues(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool boolValue = prefs.getBool(key) ?? false;
    return boolValue;
  }

  static Future<int> getIntValues(type, key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int intValue = prefs.getInt(key) ?? 0;
    return intValue;
  }

  static Future<String> getStringValues(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString(key) ?? "";
    return stringValue;
  }

  static Future<String> getStringValuesNew(key) {
    return SharedPreferences.getInstance().then((prefs) {
      String stringValue = prefs.getString(key) ?? "";
      return stringValue;
    });
  }

  void saveEmployeeCode(String? sAPEMPNO) {
    saveValues(1, "empCode", sAPEMPNO);
  }
}
