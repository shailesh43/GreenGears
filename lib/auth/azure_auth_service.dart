import 'package:flutter/services.dart';
import 'package:msal_flutter/msal_flutter.dart';
import '../config/app_config.dart';

class AzureAuthService {
  late PublicClientApplication _pca;

  /// Initialize MSAL
  Future<void> initialize() async {
    try {
      // Load msal_config.json from assets (keep as raw string)
      final String jsonString = await rootBundle.loadString('assets/msal_config.json');

      // Initialize the PublicClientApplication with the raw JSON string
      _pca = await PublicClientApplication.createPublicClientApplication(jsonString);

      print('AzureAuthService initialized successfully');
    } catch (e) {
      print('Error initializing AzureAuthService: $e');
    }
  }

  /// Login method
  Future<dynamic> login() async {
    try {
      final result = await _pca.acquireToken(AppConfig.scopes);
      return result;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }
}
