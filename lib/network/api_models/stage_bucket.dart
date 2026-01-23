import './car_request.dart';

class StageBucket {
  final String key;
  final List<CarRequest> requests;

  StageBucket({
    required this.key,
    required this.requests,
  });

  factory StageBucket.fromJson(String key, List<dynamic> list) {
    return StageBucket(
      key: key,
      requests: list
          .map((e) => CarRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
