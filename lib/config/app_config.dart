import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get tenantId => dotenv.env['TENANT_ID'] ?? '';
  static String get clientId => dotenv.env['CLIENT_ID'] ?? '';
  static String get redirectUri => dotenv.env['REDIRECT_URI'] ?? '';
  static String get scope => dotenv.env['SCOPE'] ?? 'User.Read offline_access';
  static String get userGraphUrl => dotenv.env['USER_GRAPH_URL'] ?? 'https://graph.microsoft.com/beta/me';

  static String get authorizationEndpoint =>
      'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize';

  static String get tokenEndpoint =>
      'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token';
}