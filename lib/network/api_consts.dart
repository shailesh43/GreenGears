class ApiConstants {
  String loginBaseUrl =
      'https://bizappsd.tatapower.com/dev/greengears';
  // String baseUrl = 'https://webmp.tatapower.com/c2s/api/v1';
  // String userGraphUrl = "https://graph.microsoft.com/beta/me";
  static const String loginRequest = '/MobileAppLogin';
  static String getRaiseOnLoad = '/common/getraisequeryonloaddata';
  static String getAllIncidents = '/query/postQueriesByCreatedBy';
  static String getAllQueriesFeedback = '/query/postQueriesInPathway';
  static String postQuery = '/query/postRaiseQuery';
  static String postSpocAction = '/query/postSpocActionCaptured';
  static String postFeedback = '/query/postFeedback';
  static String userRole = '/common/getemprole';
  static String saveToken = '/common/saveToken';
}