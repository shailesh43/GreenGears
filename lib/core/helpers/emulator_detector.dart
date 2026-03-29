import 'package:device_info_plus/device_info_plus.dart';

class EmulatorDetector {
  static Future<bool> isEmulator() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    return !androidInfo.isPhysicalDevice ||
        androidInfo.model.toLowerCase().contains('sdk') ||
        androidInfo.model.toLowerCase().contains('emulator') ||
        androidInfo.brand.toLowerCase().contains('generic') ||
        androidInfo.device.toLowerCase().contains('generic') ||
        androidInfo.product.toLowerCase().contains('sdk') ||
        androidInfo.hardware.toLowerCase().contains('goldfish') ||
        androidInfo.hardware.toLowerCase().contains('ranchu');
  }
}