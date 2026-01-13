class AppConfig {
  static const bool production = false;

  static const String baseApiUrl = 'http://localhost:3010/api';

  static const String clientId = '474f8122-57b6-4393-bed5-a05cb9145494';

  static const String tenantId = '04ea39e3-ac5b-4971-937c-8344c97a4509';

  static const String authority =
      'https://login.microsoftonline.com/04ea39e3-ac5b-4971-937c-8344c97a4509';

  static const String androidRedirectUri =
      'msauth://com.tatapower.greengears/fwX9a9GPV9I3xuDOLwxkrh63k3w=';

  static const List<String> scopes = [
    'user.read',
    'openid',
    'profile',
    'email',
  ];

  static const String graphMeEndpoint =
      'https://graph.microsoft.com/beta/me';
}
