import './car_request.dart';

class UserApprovalModel {
  final Map<String, List<CarRequest>> data;

  UserApprovalModel({required this.data});

  factory UserApprovalModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as Map<String, dynamic>;

    return UserApprovalModel(
      data: rawData.map(
            (stage, list) => MapEntry(
          stage,
          (list as List)
              .map((e) => CarRequest.fromJson(e))
              .toList(),
        ),
      ),
    );
  }
}
