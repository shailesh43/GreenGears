import 'car_request.dart';

class StatusFilteredRequestsModel {
  final List<CarRequest> active;
  final List<CarRequest> inactive;

  StatusFilteredRequestsModel({
    required this.active,
    required this.inactive,
  });

  factory StatusFilteredRequestsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return StatusFilteredRequestsModel(
      active: (data['active'] as List<dynamic>? ?? [])
          .map((e) => CarRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      inactive: (data['inactive'] as List<dynamic>? ?? [])
          .map((e) => CarRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
