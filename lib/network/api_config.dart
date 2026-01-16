import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3010/api';
    } else {
      return 'http://10.0.2.2:3010/api';
    }
  }
}
