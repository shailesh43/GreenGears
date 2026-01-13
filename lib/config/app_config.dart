class AppConfig {
  static const String tenantId = '04ea39e3-ac5b-4971-937c-8344c97a4509';
  static const String clientId = '474f8122-57b6-4393-bed5-a05cb9145494';

  static const String redirectUri =
      'msauth://com.tatapower.greengears/fwX9a9GPV9I3xuDOL';

  static const String scope = 'User.Read offline_access';

  static String get authorizationEndpoint =>
      'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize';

  static String get tokenEndpoint =>
      'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token';
  static String userGraphUrl = "https://graph.microsoft.com/beta/me";
}
