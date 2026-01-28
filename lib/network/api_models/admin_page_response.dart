import './stage_bucket.dart';
import './car_request.dart';

class AdminPageResponse {
  String? message;
  Map<String, StageBucket> stageBuckets = {};

  AdminPageResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      data.forEach((key, value) {
        if (value is List) {
          stageBuckets[key] = StageBucket.fromJson(key, value);
        }
      });
    }
  }
  /// Flatten all requests (useful for search)
  List<CarRequest> get allRequests =>
      stageBuckets.values.expand((e) => e.requests).toList();
}
