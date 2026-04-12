import 'dart:io';
import 'package:flutter/services.dart';

class UserCaDetector {
  // Platform channel — wired up in step 3 (MainActivity.kt)
  static const _channel = MethodChannel('com.tatapower.greengears/security');

  /// Returns true if the device has any user-installed CA certificates.
  /// On Android we delegate to a native call because Dart has no direct
  /// access to the KeyStore. On iOS, there is no programmatic API to
  /// enumerate user-installed profiles, so we return false (iOS already
  /// restricts their use more aggressively via MDM/Settings).
  static Future<bool> hasUserInstalledCACerts() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool result =
      await _channel.invokeMethod('hasUserInstalledCACerts');
      return result;
    } on PlatformException {
      // Fail safe: if we can't check, assume compromised
      return true;
    }
  }
}