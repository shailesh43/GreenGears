import 'package:device_info_plus/device_info_plus.dart';

class EmulatorDetector {
  static Future<bool> isEmulator() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    final model = androidInfo.model.toLowerCase();
    final brand = androidInfo.brand.toLowerCase();
    final device = androidInfo.device.toLowerCase();
    final product = androidInfo.product.toLowerCase();
    final hardware = androidInfo.hardware.toLowerCase();
    final manufacturer = androidInfo.manufacturer.toLowerCase();
    final fingerprint = androidInfo.fingerprint.toLowerCase();

    return !androidInfo.isPhysicalDevice ||

        // Standard Android emulator
        model.contains('sdk') ||
        model.contains('emulator') ||
        hardware.contains('goldfish') ||
        hardware.contains('ranchu') ||
        brand.contains('generic') ||
        device.contains('generic') ||
        product.contains('sdk') ||

        // NoxPlayer
        manufacturer.contains('nox') ||
        model.contains('nox') ||
        product.contains('nox') ||
        device.contains('nox') ||

        // BlueStacks
        manufacturer.contains('bluestacks') ||
        model.contains('bluestacks') ||
        product.contains('bluestacks') ||
        fingerprint.contains('bluestacks') ||

        // LDPlayer
        manufacturer.contains('ldplayer') ||
        model.contains('ldplayer') ||
        product.contains('ld') ||
        device.contains('ld_') ||

        // Generic third-party emulator signals
        fingerprint.contains('generic') ||
        fingerprint.contains('emulator') ||
        fingerprint.contains('unknown') ||
        hardware.contains('vbox') ||        // VirtualBox-based emulators
        hardware.contains('nox') ||
        product.contains('google_sdk');
  }
}